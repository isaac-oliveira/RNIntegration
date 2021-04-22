import React from 'react'
import { Text, View, StyleSheet } from 'react-native'

const App = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.hello}>Hello React Native</Text>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center'
  },
  hello: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10
  }
});

export default App