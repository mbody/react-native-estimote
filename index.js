const React = require('react-native')

function moduleSelector() {
  if (React.Platform.OS === 'android') {
      return React.NativeModules.RNEstimoteModule
  }
  return React.NativeModules.RNEstimote
}

const RNEstimote = moduleSelector()

module.exports = RNEstimote
