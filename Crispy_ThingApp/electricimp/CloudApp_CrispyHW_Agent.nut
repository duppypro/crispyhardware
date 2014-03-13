/* crispy */
/* CloudApp Agent Electric Imp Squirrel code */

/////////////////////////////////////////////////
// global constants and variables

// generic
const versionString = "crispy v00.01.2014-03-13b"
const logIndent   = ".........>.........>.........>.........>.........>.........>.........>.........>.........>.........>.........>"
logVerbosity <- 100 // higer numbers show more log messages
errorVerbosity <- 1000 // higher number shows more error messages
fakeMillis <- 42 // fake out millisecond times for debugging

///////////////////////////////////////////////
// constants for Firebase
/*

TODO: have this code self describe ThingInfo and StreamInfo by changing cloud to start ThingUuid@ttttttttttttt and StreamUuid@ttttttttttttt
Change security rules to only enable writes for current time (- some skew slop)

https://crispy-thingstream-name-server.firebaseio.com/
    allStreamInfoByUuid

https://crispy-thingstream-sessions.firebaseio.com/
    allSessionsByStreamUuid/
        2A33BB04-A035-45C8-827F-868D625BFE71-570f5ba6-963d-43e0-9af4-f91a47f0d077/
            1380061438004

https://crispy-thingstream-bigdata.firebaseio.com/
    allDataBySessionRef/
        crispy-impv00-hDzxieGblkLa-debugLog/0000000000000

*/

// which firebase to use
const refBigDataRoot = "https://crispy-thingstream-bigdata.firebaseio.com/allDataBySessionRef/" // FIXME: read this from Stream Info
const refAllSessionsByStreamUuid = "https://crispy-thingstream-name-server.firebaseio.com/allSessionsUrl/allSessionsByStreamUuid/" // FIXME: read this with GET from https://crispy-thingstream-name-server.firebaseio.com/allStreamInfoByUuid/crispy-impv00-hDzxieGblkLa-debugLog/allSessionsRef/.json
const uuidPrefix = "crispy-impv00-" // add prefix so that crispy UUIDs do not collide with other Thing UUIDs
myThingInfo <- {}
    myThingInfo.readme <- "crispy\r\nThis is a crispy HW debug logger."

// helper variables ???

///////////////////////////////////////////////
//define functions

//generic
function log(string, level) {
    local indent = logIndent.slice(0, level / 10)
    if (level <= logVerbosity)
        server.log(indent + string)
}

function error(string, level) {
    local indent = logIndent.slice(0, level / 10)
    if (level <= errorVerbosity)
        server.error(indent + string)
}

function timestamp() {
    local dateNow = date()
    return format("%010d%03d", dateNow.time, dateNow.usec / 1000)
}

// firebase specific
function putStreamValue(table, timeKey) {
    foreach (key, obj in table) {
        if (key in refBigDataByName) {
            log("PUT " + key + "/" + timeKey + "/.json", 50)
            log("PUT " + refBigDataByName[key] + "/" + timeKey + "/.json", 50)
            log(http.jsonencode(obj), 100)
            http.request(
                "PUT",
                refBigDataByName[key] + "/" + timeKey + "/.json",
                {},
                http.jsonencode(obj)
            ).sendasync(checkHttpRequestResponse)
        } else {
            error("Unknown key : " + key, 10)
        }
    }
}

http.onrequest(function(req,res) {
    local timeKey = timestamp()
    local table = req.query
    local responseString = "PUT Stream Values :"

    log("@" + timeKey + " REST REQUEST " + http.jsonencode(table), 100)    
    putStreamValue(table, timeKey)
    responseString += "\r\n-------------------\r\n"
    foreach (key, obj in table) {
        if (key in refBigDataByName) {
            responseString += "\tcurl -X PUT -d " + http.jsonencode(obj) + " "
            responseString += refBigDataByName[key] + "/" + timeKey + "/.json"
        } else {
            responseString += "\tUnknown key : " + key
        }
        responseString += "\r\n-------------------\r\n"
    }
    res.send(200, responseString)
})

device.onconnect(function() {
    log("Connect", 100)
    putStreamValue(
        {
            "debugLog" : "[Agent detected device CONNECTED]",
        },
        timestamp()
    )
    putStreamValue(
        {
            "debugLogB" : "[Agent detected device CONNECTED]",
        },
        timestamp()
    )
})

device.ondisconnect(function() { // FIXME: send info to healthstatus when disconnect 
    // BUGBUG: Agent does not detect device disconnect right away.
    log("Disconnect", 100)
    putStreamValue(
        {
            "debugLog" : "[Agent detected device *DIS*CONNECTED]",
        },
        timestamp()
    )
    putStreamValue(
        {
            "debugLogB" : "[Agent detected device *DIS*CONNECTED]",
        },
        timestamp()
    )
})

device.on("event", function(table) {
    local timeKey = timestamp()
    log("@" + timeKey + " Device sent\r\n" + http.jsonencode(table) || table, 100)
    // post to firebase
    putStreamValue(table, timeKey)
})

function checkHttpRequestResponse(m) {
    if (m.statuscode == 200) {
        log("Request Complete : " + m.body, 1100)
    } else if (m.statuscode == 201) {
        log("non-error statuscode 201 : " + m.body, 100)
    } else {
        error("REQUEST error " + m.statuscode + "\r\n" + m.body, 10)
    }
}
 
////////////////////////////////////////////////////////
// first Agent code starts here
log("BOOTING_________ : " + versionString, 0)
log("Imp Agent URL___ : " + http.agenturl(), 0)
log("Agent SW version : " + imp.getsoftwareversion(), 0)
impAgentURLRoot <- http.agenturl()
impAgentURLRoot = impAgentURLRoot.slice(0, impAgentURLRoot.find("/", "https://".len()) + 1)
timeSessionStart <- timestamp()
log("refBigDataRoot__________ : " + refBigDataRoot, 10)
thingUuid <- uuidPrefix + http.agenturl().slice(impAgentURLRoot.len())
log("thingUuid_______________ : " + thingUuid, 10)
log("timeSessionStart________ : " + timeSessionStart, 10)
streamUuidByName <- {
    "debugLog" : "debugLog-" + thingUuid,
    "debugLogB" : "debugLogB-" + thingUuid,
    "healthStatus" : "healthStatus-" + thingUuid,
}
refBigDataByName <- {
    "debugLog" : refBigDataRoot + streamUuidByName["debugLog"] + "/" + timeSessionStart,
    "debugLogB" : refBigDataRoot + streamUuidByName["debugLogB"] + "/" + timeSessionStart,
    "healthStatus" : refBigDataRoot + streamUuidByName["healthStatus"] + "/" + timeSessionStart,
}
refAllSessionsByName <- {
    "debugLog" : refAllSessionsByStreamUuid + streamUuidByName["debugLog"] + "/" + timeSessionStart,
    "debugLogB" : refAllSessionsByStreamUuid + streamUuidByName["debugLogB"] + "/" + timeSessionStart,
    "healthStatus" : refAllSessionsByStreamUuid + streamUuidByName["healthStatus"] + "/" + timeSessionStart,
}
// initialize new sessions for each out Stream
foreach (key, val in refAllSessionsByName) {
    log("PUT " + val + "/.json", 50)
    log(
        http.jsonencode({
            "__REF__" : refBigDataByName[key]
        }),
        100
    )
    checkHttpRequestResponse(
        http.request(
            "PUT",
            val + "/.json",
            {},
            http.jsonencode({
                "__REF__" : refBigDataByName[key]
            })
        ).sendsync()
    )
}

// send boot message
putStreamValue(
    {
        "debugLog" : "[BOOTING Electric Imp Agent] " + versionString,
    },
    timestamp()
)

putStreamValue(
    {
        "debugLogB" : "[BOOTING Electric Imp Agent] " + versionString,
    },
    timestamp()
)

// No more code to execute so we'll wait for messages from Device code.
// End of code.

// crispy hardware
// CloudApp Electric Imp Agent Squirrel code
