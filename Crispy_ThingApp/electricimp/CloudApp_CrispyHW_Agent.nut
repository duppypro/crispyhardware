/* crispy */
/* CloudApp Agent Electric Imp Squirrel code */

/////////////////////////////////////////////////
// global constants and variables

// generic
const versionString = "crispy v00.01.2014-05-08a"

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
function timestamp() {
    local dateNow = date()
    return format("%010u%03u000", dateNow.time, dateNow.usec / 1000)
    // FIXME: This time is not in sync with device reported time
    // Reporting millisec only because this time base is not in sync
}

// firebase specific
function putStreamValue(table, timeKey) {
    foreach (key, obj in table) {
        if (key in refBigDataByName) {
            // server.log("putStreamValue " + key + " @" + timeKey)
            // server.log("PUT " + refBigDataByName[key] + "/" + timeKey + "/.json")
            // server.log(http.jsonencode(obj))
            http.request(
                "PUT",
                refBigDataByName[key] + "/" + timeKey + "/.json",
                {},
                http.jsonencode(obj)
            ).sendasync(checkHttpRequestResponse)
        } else {
            if (key != "t") {
                server.error("Unknown key : " + key)
            }
        }
    }
}

http.onrequest(function(req,res) {
    local timeKey = timestamp()
    local table = req.query
    local responseString = "PUT Stream Values :"

    server.log("@" + timeKey + " REST REQUEST " + http.jsonencode(table))    
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
    server.log("Connect")
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
    server.log("Disconnect")
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
    // server.log("device.on() " + http.jsonencode(table) || table)
    // post to firebase
    if ("t" in table) {
        putStreamValue(table, table.t) // use local timestamp usec level from device
    } else {
        putStreamValue(table, timestamp()) // use electric imp cloud timestamp
    }
})

function checkHttpRequestResponse(m) {
    if (m.statuscode == 200) {
        // server.log("Request Complete : " + m.body)
    } else if (m.statuscode == 201) {
        server.log("non-error statuscode 201 : " + m.body)
    } else {
        server.error("REQUEST error " + m.statuscode + "\r\n" + m.body)
    }
}
 
////////////////////////////////////////////////////////
// first Agent code starts here
server.log("BOOTING_________ : " + versionString)
server.log("Imp Agent URL___ : " + http.agenturl())
server.log("Agent SW version : " + imp.getsoftwareversion())
impAgentURLRoot <- http.agenturl()
impAgentURLRoot = impAgentURLRoot.slice(0, impAgentURLRoot.find("/", "https://".len()) + 1)
timeSessionStart <- timestamp()
server.log("refBigDataRoot__________ : " + refBigDataRoot)
thingUuid <- uuidPrefix + http.agenturl().slice(impAgentURLRoot.len())
server.log("thingUuid_______________ : " + thingUuid)
server.log("timeSessionStart________ : " + timeSessionStart)
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
    server.log("PUT " + val + "/.json")
    server.log(
        http.jsonencode({
            "__REF__" : refBigDataByName[key]
        })
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
