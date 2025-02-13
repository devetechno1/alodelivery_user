importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyBzozOqwNzFWAy4v7foN4I71qo-4LsnB90",
    authDomain: "alodelivery974.firebaseapp.com",
    projectId: "alodelivery974",
    storageBucket: "alodelivery974.firebasestorage.app",
    messagingSenderId: "443729581845",
    appId: "1:443729581845:web:a0e3f65440a0e723887b1c",
    measurementId: "G-0DG54VRWY9"
});

const messaging = firebase.messaging();

messaging.setBackgroundMessageHandler(function (payload) {
    const promiseChain = clients
        .matchAll({
            type: "window",
            includeUncontrolled: true
        })
        .then(windowClients => {
            for (let i = 0; i < windowClients.length; i++) {
                const windowClient = windowClients[i];
                windowClient.postMessage(payload);
            }
        })
        .then(() => {
            const title = payload.notification.title;
            const options = {
                body: payload.notification.score
              };
            return registration.showNotification(title, options);
        });
    return promiseChain;
});
self.addEventListener('notificationclick', function (event) {
    console.log('notification received: ', event)
});