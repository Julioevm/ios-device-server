
import jester
import json
import osproc
import strutils

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

  for device in devicesTextList[1..devicesTextList.len - 2]:
    var deviceValues = device.split(' ')
    var d: Device
    d.name = deviceValues[0]
    d.version = deviceValues[1].substr(1, deviceValues[1].len - 2)
    d.udid = deviceValues[2].substr(1, deviceValues[2].len - 2)
    wdaPortCount += 1
    d.wdaPort = wdaPortCount
    jsonSeq.add(d)

  return jsonSeq
  
proc getLocalDevices(): seq =
  return execProcess("cat mock.txt | grep -v Simulator").parseDeviceList()

proc getDevicesJson(): JsonNode =
  var deviceList = getLocalDevices()
  return %* deviceList

settings:
  port = Port 5000

routes:
  get "/":
        resp %getDevicesJson()