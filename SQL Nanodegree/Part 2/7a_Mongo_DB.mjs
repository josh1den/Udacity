### MongoDB Exercises

/*
Write appropriate queries to retrive the following
*/

// Total number of events in the collection:
db.events.countDocuments({})

// Total number of events for the device with ID:
// 8f5844d2-7ab3-478e-8ea7-4ea05ab9052e
db.events.countDocuments({ deviceID: '8f5844d2-7ab3-478e-8ea7-4ea05ab9052e' })

// The total number of events that came from a Firefox browser
// and happened on or after April 20, 2019
db.events.countDocuments({
    'browser.vendor': 'firefox',
    timestamp: { $gte: ISODate('2019-04-20') }
})

// The list of the top 100 events that happened in Chrome on Windows
// sorted in reverse chronological order
db.events.find({
  'browser.vendor': 'chrome',
  'browser.os': 'windows'
}).sort({
  timestamp: -1
}).limit(100)

// Alternative
db.events.find({
  browser: { vendor: 'chrome', os: 'windows'}
}).sort({
  timestamp: -1
}).limit(100)
