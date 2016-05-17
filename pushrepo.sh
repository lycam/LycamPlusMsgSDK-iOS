#!/bin/sh
pod lib lint --allow-warnings --verbose
pod repo push coding-lycam-lycamspecs  LycamPlusMsgSDK.podspec --allow-warnings --verbose

