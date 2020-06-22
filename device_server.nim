
import jester
import json
import osproc
import strutils

const INSTRUMENTS = "instruments -s devices"
const GREP = "| grep -v Simulator"
var wdaPortCount: int = 8000

type
  Device = object
    name: string
    version: string
    udid: string
    wdaPort: int

proc `%`(d: Device): JsonNode =
  result = %[("name", %d.name), ("version", %d.version), ("udid", %d.udid), ("wdaPort", %d.wdaPort)]

proc parseDeviceList(textList: string): auto =
  let devicesTextList = textList.split('\n')
  var jsonSeq:  seq[Device]

  for device in devicesTextList[2..devicesTextList.len - 2]:
    var
      deviceName = device.substr(0, device.find('(') - 1).strip()
      deviceVersion = device.substr(device.find('(') + 1, device.find(')') - 1)
      deviceUDID = device.substr(device.find('[') + 1, device.find(']') - 1)
    var d: Device
    d.name = deviceName
    d.version = deviceVersion
    d.udid = deviceUDID
    wdaPortCount += 1
    d.wdaPort = wdaPortCount
    jsonSeq.add(d)

  return jsonSeq
  
proc getLocalDevices(): seq =
  return execProcess(INSTRUMENTS & GREP).parseDeviceList()

proc getDevicesJson(): JsonNode =
  var deviceList = getLocalDevices()
  return %* deviceList

settings:
  port = Port 5000

routes:
  get "/":
        resp %getDevicesJson()