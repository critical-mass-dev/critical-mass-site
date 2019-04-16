// The Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
const functions = require('firebase-functions');

// mail setup
const nodemailer = require('nodemailer');
const sesTransport = require('nodemailer-ses-transport');

const mailTransport = nodemailer.createTransport(
  sesTransport({
    accessKeyId: functions.config().aws.access_key_id,
    secretAccessKey: functions.config().aws.secret_access_key,
    region: functions.config().aws.region,
}));

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

// CONSTANTS
const compactsKey = 'compacts';
const compactLongFieldsKey = 'long_fields';
const usersInternalCollectionKey = 'users_internal';
const usersCollectionKey = 'users';
const pledgedKey = 'pledged';
const compactURLPrefix = 'https://criticalmass.works/compact/'

// UTIL FUNCTIONS

async function sendActivationMails(receiverMails, call, pledgeTitle, pledgeId, numActivated, threshold) {
  var mailTextPieces = [];
  mailTextPieces.push(
    '<html>You pledged to <a href="',
    compactURLPrefix, pledgeId, '">',
    pledgeTitle, "</a> if ",
    threshold, " other people did it, and ", (numActivated - 1),
    " other people have signed on.<br>",
  );
  if (call) {
    mailTextPieces.push(
      'Here is a message from the pledge creator:<hr>',
      call,
      '<hr>',
    );
  }
  mailTextPieces.push('<br>This is the only mail you will receive about this pledge. Have a good day!</html>');
  const mail = {
    from: '"Critical Mass" <noreply@criticalmass.works>',
    bcc: receiverMails,
    subject: numActivated + ' people have pledged to \'' + pledgeTitle + '\'',
    html: mailTextPieces.join(''),
  };
  await mailTransport.sendMail(mail);
}

function checkAuth(context) {
  if (!context.auth) {
    // Throwing an HttpsError so that the client gets the error details.
    throw new functions.https.HttpsError('unauthenticated', 'The function must be called ' +
        'while authenticated.');
  }
  if (!context.auth.token) {
    throw new functions.https.HttpsError('unauthenticated', 'No token');
  }
  if (!context.auth.token.email) {
    throw new functions.https.HttpsError('unauthenticated', 'No email');
  }
  if (!context.auth.token.email_verified) {
    throw new functions.https.HttpsError('unauthenticated', 'No verified email');
  }
}

// only for single key diffs
function findMapKeyDiff(smaller, larger) {
  for (var [k, v] of larger) {
    if (!smaller.has(k)) {
      return k;
    }
  }
  throw new Error('could not find key diff');
}

// EXPORTED FUNCTIONS

exports.pledge = functions.https.onCall(async (data, context) => {
  checkAuth(context);

  const compactId = data['id'];
  const threshold = data['threshold'];
  const userId = context.auth.uid;
  const userEmail = context.auth.token.email;
  if (threshold < 0 || threshold > 100000000000) {
    throw new functions.https.HttpsError('invalid-argument', 'bad pledge level');
  }

  return admin.firestore().runTransaction(async (transaction) => {
    // get user doc
    const userRef = admin.firestore().doc(usersCollectionKey + '/' + context.auth.uid);
    const userDoc = await transaction.get(userRef);
    if (compactId in userDoc.data()['pledged']) {
      throw new functions.https.HttpsError('already-exists', 'already pledged');
    }

    // get parent
    const parentRef = admin.firestore().doc(compactsKey + '/' + compactId);
    const parentDoc = await transaction.get(parentRef);

    // get internal
    const internalRef = admin.firestore().doc(compactsKey + '/' + compactId + '/pieces/internal');
    const internalDoc = await transaction.get(internalRef);

    var numUnactivated = parentDoc.get('numUnactivated');
    var numActivated = parentDoc.get('numActivated');
    const activated = internalDoc.get('unactivatedUsers');
    const unactivated = internalDoc.get('activatedUsers');

    // helper function, put user u in cohort c of map m.
    const cohortPush = (m, c, u) => {
      if (!m[c]) {
        m[c] = [];
      }
      m[c].push(u);
    }

    var newlyActivated = {};
    // add the new user to the appropriate cohort
    if (threshold <= numActivated) {
      cohortPush(activated, threshold, userId);
      numActivated += 1;
      newlyActivated[threshold] = [{u: userId, e: userEmail}];
    } else {
      cohortPush(unactivated, threshold, {u: userId, e: userEmail});
      numUnactivated += 1;
    }

    // try to cascade activations.
    var unactivatedCohorts = Object.keys(unactivated);
    unactivatedCohorts.sort((a, b) => {return a - b});
    for (var k of unactivatedCohorts) {
      if (k > numActivated + numUnactivated) {  // impossible, stop here.
        break;
      }
      var v = unactivated[k];
      if (k <= numActivated + v.length - 1) {  // activate this cohort.
        numUnactivated -= v.length;
        numActivated += v.length;
        activated[k] = v;
        newlyActivated[k] = v;
        delete unactivated[k];
      }
    }

    // TODO: move this out of the transaction.
    for (k of Object.keys(newlyActivated)) {
      mails = newlyActivated[k].map(x => x.e);
      sendActivationMails(
        mails,
        internalDoc.get('callToAction'),
        parentDoc.get('title'),
        compactId,
        numActivated,
        threshold,
      );
    }

    // update internal
    transaction.update(internalRef,
      {
        unactivatedUsers: unactivated,
        activatedUsers: activated,
      });

    // update parent
    transaction.update(parentRef,
      {
        numUnactivated: numUnactivated,
        numActivated: numActivated
      });

    // update user
    var userUpdate = {};
    userUpdate['pledged.' + compactId] = threshold;
    transaction.update(userRef, userUpdate);
    return;
  });
});

exports.unpledge = functions.https.onCall(async (data, context) => {
  checkAuth(context);

  const compactId = data['id'];
  const userId = context.auth.uid;
  const userObj = {u: userId, e: context.auth.token.email};

  return admin.firestore().runTransaction(async (transaction) => {
    // get user doc
    const userRef = admin.firestore().doc(usersCollectionKey + '/' + userId);
    const userDoc = await transaction.get(userRef);
    const threshold = userDoc.data()['pledged'][compactId];
    if (threshold === undefined) {
      throw new functions.https.HttpsError('not-found', 'not pledged');
    }

    // get internal
    var internalRef = admin.firestore().doc(compactsKey + '/' + compactId + '/pieces/internal');
    var internalDoc = await transaction.get(internalRef);
    var cohort = internalDoc.get('unactivatedUsers')[threshold];
    if (!cohort || !cohort.find(x => x.u === userId)) {
      throw new functions.https.HttpsError('failed-precondition', 'already activated or unpledged');
    }
    // get parent
    var parentRef = admin.firestore().doc(compactsKey + '/' + compactId);
    var parentDoc = await transaction.get(parentRef);

    // update internal
    var internalUpdate = {};
    internalUpdate['unactivatedUsers.' + threshold] = admin.firestore.FieldValue.arrayRemove(userObj);
    transaction.update(internalRef, internalUpdate);

    // update parent
    transaction.update(parentRef, {numUnactivated: parentDoc.get('numUnactivated') - 1});

    // update user
    var userUpdate = {};
    userUpdate['pledged.' + compactId] = admin.firestore.FieldValue.delete();
    transaction.update(userRef, userUpdate);
    return;
  });
});

exports.createUser = functions.auth.user().onCreate((user) => {
  // create the record under users_internal
  admin.firestore().doc(usersInternalCollectionKey + '/' + user.uid).set({
    'email': user.email,
    'creationTs': admin.firestore.Timestamp.now(),
  });

  // create the record under users
  admin.firestore().doc(usersCollectionKey + '/' + user.uid).set({
    'created': [],
    'pledged': {},
  });
  return true;
});

// TODO: make this idempotent?
exports.createCompact = functions.https.onCall(async (data, context) => {
  checkAuth(context);
  // check validity of data
  const maxTitleLen = 500;
  const maxDescriptionLen = 10000;
  const maxCallToActionLen = 10000;

  const title = data['title'];
  const description = data['description'];
  const call = data['callToAction'];

  if (!title || title.length > maxTitleLen) {
    throw new functions.https.HttpsError('invalid-argument', 'Bad title');
  }
  if (!description || description.length > maxDescriptionLen) {
    throw new functions.https.HttpsError('invalid-argument', 'Bad description');
  }
  if (call && call.length > maxCallToActionLen) {
    throw new functions.https.HttpsError('invalid-argument', 'Bad call to action');
  }
  // create the parent doc
  var parentDocContent = {
    'title': title,
    'numActivated': 0,
    'numUnactivated': 0,
    'creationTs': admin.firestore.Timestamp.now(),
  };
  if (data['showEmail']) {
    parentDocContent['creatorEmail'] = context.auth.token.email;
  }

  var parentRefPromise = admin.firestore().collection(compactsKey).add(parentDocContent);
  var docId = (await parentRefPromise).id;

  // create the long fields doc
  const longFieldsRef = admin.firestore().doc(compactsKey + '/' + docId + '/pieces/long_fields').set({'description': description});

  // create the private doc
  privateDocContent = {
    'creatorId': context.auth.uid,
    'activatedUsers': {},
    'unactivatedUsers': {},
  }
  if (call) {
    privateDocContent['callToAction'] = call;
  }
  const privateDocRef = admin.firestore().doc(compactsKey + '/' + docId + '/pieces/internal').set(privateDocContent);

  // write creator log to the user doc
  const creatorUpdate = admin.firestore().doc(usersCollectionKey + '/' + context.auth.uid).update({'created': admin.firestore.FieldValue.arrayUnion(docId)});
  // TODO: use a transaction instead?
  await creatorUpdate;
  await privateDocRef;
  await longFieldsRef;
  return {
    'id': docId,
  }
});
