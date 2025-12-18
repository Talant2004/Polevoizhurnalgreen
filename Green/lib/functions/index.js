const functions = require('firebase-functions');
const { google } = require('googleapis');
const admin = require('firebase-admin');
const sheets = google.sheets('v4');

admin.initializeApp();

exports.saveSample = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'Требуется авторизация');
  }

  try {
    const auth = new google.auth.GoogleAuth({
      keyFile: './service-account-key.json',
      scopes: ['https://www.googleapis.com/auth/spreadsheets'],
    });
    const client = await auth.getClient();

    const {
      sampleNumber,
      inspectedArea,
      pestCount,
      pestType,
      photoUrl,
      gpsCoordinates,
      date,
      userId,
      workCardData,
    } = data;

    if (userId !== context.auth.uid) {
      throw new functions.https.HttpsError('permission-denied', 'Недостаточно прав');
    }

    let spreadsheetId = 'YOUR_SPREADSHEET_ID';
    const configDoc = await admin.firestore().collection('config').doc('sheets').get();
    if (configDoc.exists && configDoc.data().spreadsheetId) {
      spreadsheetId = configDoc.data().spreadsheetId;
    }

    const sheetInfo = await sheets.spreadsheets.get({ auth: client, spreadsheetId });
    if (sheetInfo.data.sheets[0].properties.gridProperties.rowCount > 500000) {
      const newSheet = await sheets.spreadsheets.create({
        auth: client,
        resource: { properties: { title: `PestControlData_${Date.now()}` } },
      });
      spreadsheetId = newSheet.data.spreadsheetId;
      await admin.firestore().collection('config').doc('sheets').set({ spreadsheetId });
    }

    const values = [
      [
        sampleNumber,
        inspectedArea,
        pestCount,
        pestType,
        photoUrl || '',
        gpsCoordinates,
        date,
        userId,
        workCardData.activityType,
        workCardData.workType,
        workCardData.location,
        workCardData.culture,
        workCardData.developmentPhase,
        workCardData.farmName,
        workCardData.area,
      ],
    ];
    await sheets.spreadsheets.values.append({
      auth: client,
      spreadsheetId,
      range: 'Sheet1!A:O',
      valueInputOption: 'RAW',
      resource: { values },
    });

    return { message: 'Проба сохранена', photoUrl, spreadsheetId };
  } catch (error) {
    console.error(error);
    throw new functions.https.HttpsError('internal', 'Ошибка сохранения пробы', error.message);
  }
});