/* crispy hardware
/* ThingApp Device Electric Imp Squirrel code */

/////////////////////////////////////////////////
// global constants and variables

// generic
const versionString = "crispy hardware v00.01.2015-08-14a"
impeeID <- hardware.getimpeeid() // cache the impeeID FIXME: is this necessary for speed?
offsetMicros <- 0 // set later to microsseconds % 1000000 when time() rolls over //FIXME: need a better timesync solution here
const sleepforTimeoutSecs = 60 // seconds idle before decrementing idleCount
const idleCountMaxTimeouts = 22 //3 // number sleepforTimeoutSecs periods before server.sleepfor()
const sleepforDurationSecs = 10800//10800 == 3hrs //300 // seconds to stay in deep sleep (wakeup is a reboot)
idleCount <- idleCountMaxTimeouts // Current count of idleCountMaxTimeouts timer

active <- false

// configuration variables
wakeupPin      <- hardware.pin1
vBattPin       <- hardware.pin2
serialPort     <- hardware.uart57
serialPort_RX  <- hardware.pin7
serialPortB    <- hardware.uart1289
serialPortB_RX <- hardware.pin9

// app specific globals

///////////////////////////////////////////////
//define functions

// start with generic functions
function timestamp() {
    local t, t2, m
    t = time() // CONSTRAINT: t= and m= should be atomic but aren't
    m = hardware.micros()
    t2 = time()
    // m might be negative, make it not so
    if (m < 0) {
        m = (m % 1073741824) + 1073741824
    }
    if (t2 > t) { // check if time() seconds rolled over
        offsetMicros = m % 1000000// re-calibrate offsetMicros
        // if (offsetMicros < 0) {
        //     offsetMicros += 1000000 // Squirrel mod is remainder, not modulos
        // }
        m = (m + 1000000 - offsetMicros) % 1000000
        // if (m < 0) {
        //     m += 1000000 // Squirrel mod is remainder, not modulos
        // }
    } else {
        m = (m + 1000000 - offsetMicros) % 1000000
        // if (m < 0) {
        //     m += 1000000 // Squirrel mod is remainder, not modulos
        // }
        if (m < lastMicros && lastUTCSeconds == t2) {
            // we rolled over and didn't catch it
            t2 = t2 + 1
        }
    }
    lastMicros = m
    lastUTCSeconds = t2
    return format("%010u%06u", t2, m)
        // return microseconds since Unix epoch
}

function checkActivity() {
// checkActivity re-schedules itself every sleepforTimeoutSecs
// FIXME: checkActivity should be more generic
    // server.log("checkActivity() every " + sleepforTimeoutSecs + " secs.")
    // let the agent know we are still alive
    server.log("offsetMicros=" + offsetMicros)
    server.log("hardware.micros()=" + hardware.micros())
    agent.send(
        "event",
        {
            "healthStatus" : {
                "keepAlive": idleCount,
                // "vBattPin": getVBatt(),
            },
            "t" : timestamp(),
        }
    )

    server.log("idle : " + idleCount)

    if (active || serialPort_RX.read() || serialPortB_RX.read()) {
        active = false
        idleCount = idleCountMaxTimeouts // restart idle count down
    } else {
        if (idleCount == 0) {
            idleCount = idleCountMaxTimeouts
            server.log("No activity for " + sleepforTimeoutSecs * idleCountMaxTimeouts + " to " + sleepforTimeoutSecs * (idleCountMaxTimeouts + 1) + " secs.\r\nGoing to deepsleep for " + (sleepforDurationSecs / 60.0) + " minutes.")
            //
            // do app specific shutdown stuff here
            //
            agent.send(
                "event",
                {
                    "healthStatus" : {
                        "sleepforDurationSecs": sleepforDurationSecs,
                    },
                    "t" : timestamp(),
                }
            )
            imp.onidle(function() { server.sleepfor(sleepforDurationSecs) })  // go to deepsleep if no activity for sleepforTimeoutSecs
        } else {
            idleCount -= 1
            imp.setpowersave(true) // FIXME: currently uneccessary, we are always in 5mA powersave mode
        }
    }
    imp.wakeup(sleepforTimeoutSecs, checkActivity) // re-schedule self
} // checkActivity

function processCommand(commandString, port) {
    local message = {
        "t" : timestamp()
    }

    message[port] <- commandString
    agent.send(
        "event",
         message
    )
}

function readSerialPort() {
    // Get first byte
    local timeKey = timestamp()
    local b = serialPort.read()

    // server.log("activity on serial port")
    active = true // signal activity to keep imp awake
    while (b != -1) {
        // process byte
        if (b != '\r') {
            serialString.writen(b, 'b')
            // server.log("b = " + b + ", serialString.len() = " + serialString.len())
            if ( (serialString.tell() >= serialStringMaxLength)
            ||   (b == '\n') ) {
                local string = format("%s", "" + serialString)
                processCommand(string, "debugLog")
                serialString.resize(0)
            }
        }
        b = serialPort.read()
    }
}

function readSerialPortB() {
    // Get first byte
    local timeKey = timestamp()
    local b = serialPortB.read()

    // server.log("activity on serial port")
    active = true // signal activity to keep imp awake
    while (b != -1) {
        // process byte
        if (b != '\r') {
            serialString.writen(b, 'b')
            // server.log("b = " + b + ", serialString.len() = " + serialString.len())
            if ( (serialString.tell() >= serialStringMaxLength)
            ||   (b == '\n') ) {
                local string = format("%s", "" + serialString)
                processCommand(string, "debugLogB")
                serialString.resize(0)
            }
        }
        b = serialPortB.read()
    }
}

////////////////////////////////////////////////////////
// first code starts here

wakeupPin.configure(DIGITAL_IN_WAKEUP) // let a button wake us up
imp.setpowersave(true) // start in low power mode.
/******* http://electricimp.com/docs/api/imp/setpowersave/
Power-save mode is disabled by default; this means the WiFi radio receiver is enabled constantly. This results in the lowest latency for data transfers, but a high power drain (~60-80mA at 3.3v).

Enabling power-save mode drops this down to < 5mA when the radio is idle (i.e., between transactions with the server). The down-side is added latency on received data transfers, which can be as high as 250ms.
*******/

// Send status to know we are alive
server.log("BOOTING " + versionString + " deviceId=" + hardware.getdeviceid() + " MAC:" + imp.getmacaddress())
server.log("imp software version : " + imp.getsoftwareversion())
server.log("connected to WiFi : " + imp.getbssid())
server.log("____ -300 % 1000000 = " + -300 % 1000000)

// BUGBUG: below needed until newer firmware!?  See http://forums.electricimp.com/discussion/comment/4875#Comment_2714
// imp.enableblinkup(true)

lastUTCSeconds <- 0
newSeconds <- time()
do {
    lastUTCSeconds = newSeconds
    newSeconds = time()
    offsetMicros = hardware.micros()
} while (newSeconds == lastUTCSeconds) // wait for seonds to roll over
offsetMicros = hardware.micros() % 1000000
if (offsetMicros < 0) {
    offsetMicros += 1000000 // Squirrel mod is remainder, not modulos
}
lastUTCSeconds = newSeconds
lastMicros <- offsetMicros

// this re-calibrates if timestamp() is read at a seonds rollover
// FIXME: re-calibrate more often?
server.log("offsetMicros = " + offsetMicros)

serialStringMaxLength <- 80
serialString <- blob(0)
seriialLastTime <- timestamp()
serialPort.configure(230400, 8, PARITY_NONE, 1, NO_CTSRTS, readSerialPort)
serialPortB.configure(230400, 8, PARITY_NONE, 1, NO_CTSRTS, readSerialPortB)

agent.send(
    "event",
     {
        "debugLog" : "[BOOTING Electric Imp Device] " + versionString,
        "t" : timestamp(),
     }
)
agent.send(
    "event",
     {
        "debugLogB" : "[BOOTING Electric Imp Device] " + versionString,
        "t" : timestamp(),
     }
)

checkActivity() // kickstart checkActivity, this re-schedules itself every sleepforTimeoutSecs seconds
// FIXME: checkActivity waits from sleepforTimeoutSecs to sleepforTimeoutSecs*2.  Make this more constant.

// No more code to execute so we'll sleep until an interrupts from serial or pin 1
// End of code.

// crispy hardware
// ThingApp Imp Device Squirrel code */
