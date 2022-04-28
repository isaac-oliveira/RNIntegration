# Integração do React Native com aplicativos existentes (Kotlin e Swift)

Nesse tutorial irei mostrar como fazer a integração do react native com código nativo já existente. Esse é um tópico muito importante para a carreira de nós devs RN, pois é recorrente que algumas empresas necessitem migra seus apps nativos para alguma forma híbrida, existem exemplos como Airbnb que migrou para o RN e o Nubank para o flutter, além também de ajudar no conhecimento do funcionamento da biblioteca.

## Criando projeto React Native

Primeiro navegue até a pasta na qual você quer deixar o seu projeto RN e execute:

```cmd
yarn init -y
```

Esse script irá criar o `package.json` do nosso projeto.

Nesse momento vamos adicionar o `react` e `react-native` no nosso projeto, execute:

```cmd
yarn add react-native
```

Isso imprimirá uma mensagem semelhante à seguinte (role para cima na saída do yarn para ver):

`warning " > react-native@0.68.1" has unmet peer dependency "react@17.0.2"`

Agora para instalar o `react`, rode:

```cmd
yarn add react@17.0.2 // Essa versão tem que a mesma da mensagem citada acima
```

Vamos criar nossa primeira tela, para isso crie o arquivo `App.js` com o conteúdo abaixo:

```js
import React from "react";
import { Text, View, StyleSheet } from "react-native";

const App = () => {
  return (
    <View style={styles.container}>
      <Text style={styles.hello}>Hello React Native</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
  },
  hello: {
    fontSize: 20,
    textAlign: "center",
    margin: 10,
  },
});

export default App;
```

Nesse momento precisamos fazer o registro do app, para o lado nativo reconhece-lô futuramente, para isso criamos o `index.js`:

```js
import { AppRegistry } from "react-native";
import App from "./App";

AppRegistry.registerComponent("RNIntegration", () => App);
```

Com isso, o lado do RN está pronto.

## Integrando com o Android (Kotlin)

Para iniciarmos a integração, é necessário move/copiar a pasta do nosso projeto Android para a pasta do RN, feito isso, renomei a pasta para `android`.

### Configurando o maven

Adicione a dependência React Native e JSC ao arquivo build.gradle do seu aplicativo:

```js
dependencies {
    ...
    implementation "com.facebook.react:react-native:+" // From node_modules
    implementation "org.webkit:android-jsc:+"
}
```

Adicione uma entrada para os diretórios locais do React Native e do JSC maven ao build.gradle da raíz do projeto

```js
allprojects {
     repositories {
         maven {
             // All of React Native (JS, Android binaries) is installed from npm
             url "$rootDir/../node_modules/react-native/android"
         }
         maven {
             // Android JSC is installed from npm
             url("$rootDir/../node_modules/jsc-android/dist")
         }
         google()
         jcenter()
     }
```

### Enable native modules autolinking

Adicione no `settings.gradle` a seguinte linha:

```js
apply from: file("../node_modules/@react-native-community/cli-platform-android/native_modules.gradle"); applyNativeModulesSettingsGradle(settings)
```

Em seguinda no `app/build.gradle`, adicione:

```js
apply from: file("../../node_modules/@react-native-community/cli-platform-android/native_modules.gradle"); applyNativeModulesAppBuildGradle(project)
```

### Configurando permissões

No `androidManifest.xml` adicione:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

Em seguida adicione o devmenu com a seguinte linha:

```xml
<activity android:name="com.facebook.react.devsupport.DevSettingsActivity" />
```

### Cleartext Traffic (API level 28+)​

Aplique a opção usesCleartextTraffic ao seu Debug AndroidManifest.xml

```xml
<!-- ... -->
<application
  android:usesCleartextTraffic="true" tools:targetApi="28" >
  <!-- ... -->
</application>
<!-- ... -->
```

### Criando a Activity do React Native

Crie um arquivo `MyReactActivity.kt` dentro dos seus pacotes e cole o conteúdo abaixo:

```kt
package your.package.name

 import android.os.Bundle
 import android.view.KeyEvent
 import androidx.appcompat.app.AppCompatActivity
 import com.facebook.react.ReactInstanceManager
 import com.facebook.react.ReactRootView
 import com.facebook.react.common.LifecycleState
 import com.facebook.react.modules.core.DefaultHardwareBackBtnHandler
 import com.facebook.react.shell.MainReactPackage
 import com.facebook.soloader.SoLoader

 class MyReactActivity : AppCompatActivity(), DefaultHardwareBackBtnHandler {
     private var mReactRootView: ReactRootView? = null
     private var mReactInstanceManager: ReactInstanceManager? = null
     override fun onCreate(savedInstanceState: Bundle?) {
         super.onCreate(savedInstanceState)
         SoLoader.init(this, false)

         mReactRootView = ReactRootView(this);
         mReactInstanceManager = ReactInstanceManager.builder()
             .setApplication(application)
             .setCurrentActivity(this)
             .setBundleAssetName("index.android.bundle")
             .setJSMainModulePath("index")
             .addPackage(MainReactPackage())
             .setUseDeveloperSupport(BuildConfig.DEBUG)
             .setInitialLifecycleState(LifecycleState.RESUMED)
             .build()
         mReactRootView?.startReactApplication(mReactInstanceManager, "RNIntegration")
         setContentView(mReactRootView)
     }

     override fun invokeDefaultOnBackPressed() {
         super.onBackPressed()
     }
 }
```

Agora precisamos chamar essa activity no código android, para isso:

```kt
val intent = Intent(this@MainActivity, MyReactActivity::class.java)
startActivity(intent)
```

## Integrando com o iOS (Swift)

Para iniciarmos a integração, é necessário move/copiar a pasta do nosso projeto iOS para a pasta do RN, feito isso, renomei a pasta para `ios`.

Próximo passo é criar o `ios/Podfile` com a seguinte configuração:

```rb
require_relative '../node_modules/react-native/scripts/react_native_pods'
 require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'

 platform :ios, '10.0'

 target 'YourProjectName' do
   config = use_native_modules!
   use_react_native!(
     :path => config[:reactNativePath],
     # to enable hermes on iOS, change `false` to `true` and then install pods
     :hermes_enabled => false
   )

   post_install do |installer|
     react_native_post_install(installer)
   end
 end
```

Depois de criar seu Podfile, você está pronto para instalar o pod React Native.

```cmd
pod install
```

No `Info.plist` adicione:

```xml
<key>NSAppTransportSecurity</key>
 	<dict>
 		<key>NSExceptionDomains</key>
 		<dict>
 			<key>localhost</key>
 			<dict>
 				<key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
 				<true/>
 			</dict>
 		</dict>
 	</dict>
```

Em seguida crie uma `ViewController` para o RN, aqui nomeamos como `RNViewController.swift`:

```swift
import Foundation
 import React

 class RNViewManager: NSObject {
     var bridge: RCTBridge?

     static let sharedInstance = RNViewManager()

     func createBridgeIfNeeded() -> RCTBridge {
         if bridge == nil {
             bridge = RCTBridge.init(delegate: self, launchOptions: nil)
         }
         return bridge!
     }

     func viewForModule(_ moduleName: String, initialProperties: [String : Any]?) -> RCTRootView {
         let viewBridge = createBridgeIfNeeded()
         let rootView: RCTRootView = RCTRootView(
             bridge: viewBridge,
             moduleName: moduleName,
             initialProperties: initialProperties)
         return rootView
     }
 }

 extension RNViewManager: RCTBridgeDelegate {
     func sourceURL(for bridge: RCTBridge!) -> URL! {
         #if DEBUG
             return URL(string: "http://localhost:8081/index.bundle?platform=ios")
         #else
             return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
         #endif
     }
 }
```

Agora vamos chamar a `ViewController` do React Native:

```swift
@IBAction func BtnGoReactView(_ sender: Any) {
    let jsCodeLocation = URL(string: "http://localhost:8081/index.bundle?platform=ios")
    let rootView = RCTRootView(
        bundleURL: jsCodeLocation!,
        moduleName: "RNIntegration",
        initialProperties: nil,
        launchOptions: nil)

    let reactNativeVC = UIViewController()
    reactNativeVC.view = rootView
    reactNativeVC.modalPresentationStyle = .fullScreen
    present(reactNativeVC, animated: true)
}
```

Por último, vamos adicionar os headers da Bridge:

`YourProjectName-Bridging-Header.h`

```swift
#import <React/RCTBridgeModule.h>
#import <React/RCTViewManager.h>
#import <React/RCTBridge.h>
#import <React/RCTUIManager.h>
```
