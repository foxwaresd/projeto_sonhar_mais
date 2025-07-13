const functions = require('firebase-functions');
const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({
    storageBucket: "sonhar-mais.firebasestorage.app"
  });
}

// --- Função 1: Processamento de Rosto ---
exports.processFaceForEmbedding = functions.https.onCall(
  {
    timeoutSeconds: 120, // 2 minutos para dar tempo de baixar e processar
    memory: '1GiB',     // 1GB de memória para as bibliotecas de IA
  },
  async (data, context) => {

    const faceapi = require('face-api.js');
    const tf = require('@tensorflow/tfjs');
    const { Canvas, Image, ImageData, loadImage } = require('canvas');
    const path = require('path');
    const os = require('os');
    const fs = require('fs');

    faceapi.env.monkeyPatch({ Canvas, Image, ImageData });

    const loadModelsFromStorage = async () => {
      if (global.modelsLoaded) { return; }
      console.log('Iniciando download dos modelos...');
      const bucket = admin.storage().bucket();
      const modelsPath = path.join(os.tmpdir(), 'models');
      if (!fs.existsSync(modelsPath)) {
        fs.mkdirSync(modelsPath, { recursive: true });
      }
      const modelFiles = [
        'ssd_mobilenetv1_model-shard1', 'ssd_mobilenetv1_model-shard2', 'ssd_mobilenetv1_model-weights_manifest.json',
        'face_landmark_68_model-shard1', 'face_landmark_68_model-weights_manifest.json',
        'face_recognition_model-shard1', 'face_recognition_model-shard2', 'face_recognition_model-weights_manifest.json',
      ];
      try {
        await Promise.all(modelFiles.map(async (fileName) => {
          const destination = path.join(modelsPath, fileName);
          await bucket.file(`face-api-models/${fileName}`).download({ destination });
        }));
        await faceapi.nets.ssdMobilenetv1.loadFromDisk(modelsPath);
        await faceapi.nets.faceLandmark68Net.loadFromDisk(modelsPath);
        await faceapi.nets.faceRecognitionNet.loadFromDisk(modelsPath);
        global.modelsLoaded = true;
      } catch (error) {
        console.error('Erro CRÍTICO ao baixar ou carregar modelos:', error);
        throw new Error('Falha ao preparar modelos de ML.');
      }
    };

    const payload = data.data || data;
    const { imageUrl } = payload;

    if (!imageUrl) {
      throw new functions.https.HttpsError('invalid-argument', 'URL da imagem é obrigatória.');
    }

    try {
      await loadModelsFromStorage();
      const bucket = admin.storage().bucket();
      const filePath = decodeURIComponent(new URL(imageUrl).pathname.split('/o/')[1].split('?')[0]);
      const file = bucket.file(filePath);
      const [fileBuffer] = await file.download();
      const img = await loadImage(fileBuffer);
      const detection = await faceapi.detectSingleFace(img, new faceapi.SsdMobilenetv1Options()).withFaceLandmarks().withFaceDescriptor();

      if (!detection) {
        throw new functions.https.HttpsError('not-found', 'Nenhum rosto detectado na imagem.');
      }

      const faceEmbedding = Array.from(detection.descriptor);
      return { success: true, faceEmbedding: faceEmbedding };

    } catch (error) {
      console.error('Erro no processamento do rosto:', error);
      if (error instanceof functions.https.HttpsError) { throw error; }
      throw new functions.https.HttpsError('internal', 'Falha interna ao processar a imagem.');
    }
});


// --- Função 2: Gerar ID Sequencial e Salvar Usuário ---
exports.generateSequentialUserIdAndSave = functions.https.onCall(
  {
    timeoutSeconds: 60,  // 1 minuto é suficiente
    memory: '512MiB',   // 512MB é suficiente, pois não usa IA
  },
  async (data, context) => {

    const payload = data.data || data;
    const { userData, targetCollection } = payload;

    if (!userData || !targetCollection) {
      throw new functions.https.HttpsError('invalid-argument', 'Dados do usuário e coleção alvo são obrigatórios.');
    }

    let counterDocId;
    if (targetCollection.includes('receptora')) {
      counterDocId = 'user_id_receptora';
    } else if (targetCollection.includes('doadoras')) {
      counterDocId = 'user_id_doadora';
    } else {
      throw new functions.https.HttpsError('invalid-argument', `Coleção alvo '${targetCollection}' não tem um contador definido.`);
    }

    const counterRef = admin.firestore().collection('counters').doc(counterDocId);

    try {
      let newUserId;
      await admin.firestore().runTransaction(async (transaction) => {
        const counterDoc = await transaction.get(counterRef);
        if (!counterDoc.exists) {
          throw new Error(`Documento contador '${counterDocId}' não foi encontrado!`);
        }
        const lastId = counterDoc.data().current_id;
        newUserId = lastId + 1;
        transaction.update(counterRef, { current_id: newUserId });
        const newUserDocRef = admin.firestore().collection(targetCollection).doc(String(newUserId));
        transaction.set(newUserDocRef, {
          ...userData,
          sequential_id: newUserId,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
      });
      return { success: true, userId: newUserId };
    } catch (error) {
      console.error("Erro ao gerar ID sequencial e salvar usuário:", error);
      throw new functions.https.HttpsError('internal', 'Falha ao criar novo usuário com ID sequencial.', error.message);
    }
});
// --- Função 1: Listar Usuários ---
exports.listUsers = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'A chamada deve ser autenticada.');
  }

  try {
    const listUsersResult = await admin.auth().listUsers(1000);
    const users = listUsersResult.users.map(userRecord => ({
      uid: userRecord.uid,
      email: userRecord.email,
      creationTime: userRecord.metadata.creationTime,
      lastSignInTime: userRecord.metadata.lastSignInTime,
    }));
    return { users };
  } catch (error) {
    console.error('Erro ao listar usuários:', error);
    throw new functions.https.HttpsError('internal', 'Falha ao listar usuários.', error.message);
  }
});


// --- Função 2: Alterar a Senha de um Usuário Específico ---
exports.updateUserPassword = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'A chamada deve ser autenticada.');
  }

  const { uid, newPassword } = data;

  if (!uid || !newPassword) {
    throw new functions.https.HttpsError('invalid-argument', 'UID e nova senha são obrigatórios.');
  }
  if (newPassword.length < 6) {
    throw new functions.https.HttpsError('invalid-argument', 'A senha deve ter ao menos 6 caracteres.');
  }

  try {
    await admin.auth().updateUser(uid, { password: newPassword });
    return { success: true, message: `Senha do usuário ${uid} atualizada com sucesso.` };
  } catch (error) {
    console.error('Erro ao atualizar a senha do usuário:', error);
    throw new functions.https.HttpsError('internal', 'Falha ao atualizar a senha do usuário.', error.message);
  }
});


// --- Função 3: Excluir um Usuário Específico ---
exports.deleteUser = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'A chamada deve ser autenticada.');
  }

  const userRecord = await admin.auth().getUser(context.auth.uid);
  if (!userRecord.customClaims || !userRecord.customClaims.admin) {
     throw new functions.https.HttpsError('permission-denied', 'Apenas administradores podem excluir usuários.');
   }
   if (context.auth.uid === data.uid) {
     throw new functions.https.HttpsError('permission-denied', 'Não é possível excluir sua própria conta por este método.');
   }

  const { uid } = data;

  if (!uid) {
    throw new functions.https.HttpsError('invalid-argument', 'UID é obrigatório para exclusão.');
  }

  try {
    await admin.auth().deleteUser(uid);
    return { success: true, message: `Usuário ${uid} excluído com sucesso.` };
  } catch (error) {
    console.error('Erro ao excluir usuário:', error);
    throw new functions.https.HttpsError('internal', 'Falha ao excluir o usuário.', error.message);
  }
});