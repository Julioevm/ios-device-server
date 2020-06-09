
import jester
import json
import osproc
import strutils

proc parseDeviceList(textList: string): seq =
  var finalList = textList.split('\n')
  return finalList[1..finalList.len-2]
  
proc getLocalDevices(): seq =
  return execProcess("instruments -s devices").parseDeviceList()

proc getDevicesJson(): JsonNode =
  var deviceList = getLocalDevices()
  return %* deviceList

settings:
  port = Port 5000

routes:
  get "/":
        resp %getDevicesJson()