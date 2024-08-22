const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendBookingNotifications = functions.firestore
    .document('bookings/{bookingId}')
    .onCreate((snap, context) => {
        const data = snap.data();
        const customerToken = data.customerToken;
        const providerToken = data.providerToken;

        const payloadToCustomer = {
            notification: {
                title: 'Booking Confirmation',
                body: 'Your booking has been confirmed!'
            },
            token: customerToken
        };

        const payloadToProvider = {
            notification: {
                title: 'New Booking',
                body: 'A new booking is made. Accept or reject?'
            },
            token: providerToken
        };

        return Promise.all([
            admin.messaging().send(payloadToCustomer).catch(error => {
                console.error("Error sending to customer:", error);
            }),
            admin.messaging().send(payloadToProvider).catch(error => {
                console.error("Error sending to provider:", error);
            })
        ]);
    });
