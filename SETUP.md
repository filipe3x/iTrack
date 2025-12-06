# FixSleep - Guia Completo de Setup

Este guia fornece instruções passo a passo para configurar e executar o projeto FixSleep no Xcode.

---

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Estrutura do Projeto](#estrutura-do-projeto)
3. [Configuração Inicial](#configuração-inicial)
4. [Adicionar Arquivos ao Xcode](#adicionar-arquivos-ao-xcode)
5. [Configurar Capabilities](#configurar-capabilities)
6. [Configurar Signing](#configurar-signing)
7. [Build Settings](#build-settings)
8. [Compilar e Executar](#compilar-e-executar)
9. [Testes](#testes)
10. [Troubleshooting](#troubleshooting)
11. [Próximos Passos](#próximos-passos)

---

## 🔧 Pré-requisitos

### Hardware
- **Mac** com macOS 13.0 (Ventura) ou superior
- **iPhone** com iOS 14.0+ (para testes)
- **Apple Watch Series 4+** com watchOS 7.0+ (para testes)
- Cabo USB para conectar dispositivos

### Software
- **Xcode 14.2** ou superior
  - Download: [App Store](https://apps.apple.com/app/xcode/id497799835)
  - Ou: `xcode-select --install` (Command Line Tools)
- **Apple Developer Account**
  - Gratuito para desenvolvimento local
  - Pago ($99/ano) para distribuição na App Store

### Conhecimento Recomendado
- Swift e SwiftUI básico
- HealthKit fundamentals
- WatchKit/WatchConnectivity basics
- Git básico

---

## 📁 Estrutura do Projeto

O projeto está organizado da seguinte forma:

```
iTrack/
├── FixSleep/                           # Projeto Xcode
│   ├── FixSleep.xcodeproj/            # Arquivo do projeto
│   ├── FixSleep/                      # iOS App Target
│   │   ├── FixSleepApp.swift         # Entry point iOS
│   │   ├── ContentView.swift         # Main navigation
│   │   ├── Info.plist                # Permissões iOS
│   │   ├── Views/
│   │   │   ├── DashboardView.swift   # Dashboard principal
│   │   │   ├── EventLogView.swift    # Histórico de eventos
│   │   │   ├── SettingsView.swift    # Configurações
│   │   │   └── OnboardingView.swift  # Primeira configuração
│   │   └── Services/
│   │       ├── WatchConnectivityManager.swift
│   │       └── NotificationManager.swift
│   │
│   ├── FixSleep Watch Watch App/      # watchOS App Target
│   │   ├── FixSleepWatchApp.swift    # Entry point watchOS
│   │   ├── ContentView.swift         # Watch navigation
│   │   ├── Info.plist                # Permissões watchOS
│   │   ├── Views/
│   │   │   ├── MonitoringView.swift  # Monitoramento HR
│   │   │   ├── EventListView.swift   # Lista de eventos
│   │   │   └── SettingsView.swift    # Configurações Watch
│   │   └── Services/
│   │       ├── HeartRateMonitor.swift      # HealthKit monitor
│   │       ├── DetectionEngine.swift       # Algoritmo detecção
│   │       ├── HapticManager.swift         # Haptics/Alerts
│   │       └── ExtensionDelegate.swift     # Lifecycle
│   │
│   └── Shared/                        # Código compartilhado
│       ├── Models/
│       │   ├── HeartRateData.swift   # Modelo HR/HRV
│       │   ├── Event.swift           # Modelo evento
│       │   └── Settings.swift        # Modelo settings
│       ├── Services/
│       │   ├── HealthKitManager.swift     # Interface HealthKit
│       │   └── DataManager.swift          # Persistência
│       ├── Configuration/
│       │   └── AppConfiguration.swift     # Config centralizada
│       └── Theme/
│           ├── AppTheme.swift        # Cores e estilos
│           ├── AppIcons.swift        # Ícones SF Symbols
│           ├── BackgroundEffects.swift    # Efeitos visuais
│           └── ThemeComponents.swift      # Componentes reutilizáveis
│
├── iOS/                               # Código fonte iOS (original)
├── watchOS/                           # Código fonte watchOS (original)
├── Shared/                            # Código fonte Shared (original)
├── CLAUDE.md                          # Guia do projeto
├── ARCHITECTURE.md                    # Arquitetura técnica
├── DESIGN.md                          # Design e UX
└── SETUP.md                           # Este arquivo
```

---

## 🚀 Configuração Inicial

### Passo 1: Clone o Repositório

```bash
git clone https://github.com/filipe3x/iTrack.git
cd iTrack
```

### Passo 2: Abrir o Projeto no Xcode

1. Navegue até a pasta `FixSleep/`
2. Duplo-clique em **FixSleep.xcodeproj**
3. O Xcode abrirá automaticamente

**Ou via linha de comando:**
```bash
cd FixSleep
open FixSleep.xcodeproj
```

### Passo 3: Verificar Estrutura no Xcode

No **Project Navigator** (⌘1), você deve ver:
```
▼ FixSleep
  ▼ FixSleep                    (iOS app target)
  ▼ FixSleep Watch Watch App     (watchOS app target)
  ▼ FixSleepTests
  ▼ FixSleepUITests
  ▼ FixSleep Watch Watch AppTests
  ▼ FixSleep Watch Watch AppUITests
  ▼ Products
```

---

## 📦 Adicionar Arquivos ao Xcode

Os arquivos foram copiados para o sistema de arquivos, mas **precisam ser adicionados aos targets corretos no Xcode**.

### Passo 1: Adicionar Pasta Shared aos Targets

1. **No Finder**, localize a pasta `FixSleep/Shared/`
2. **Arraste** a pasta `Shared/` para dentro do Xcode, sobre o grupo **FixSleep** no Project Navigator
3. Na janela que aparece, configure:
   - ✅ **Copy items if needed** (desmarque, os arquivos já estão no lugar)
   - ✅ **Create groups** (não "Create folder references")
   - ✅ **Add to targets:**
     - ✅ FixSleep (iOS)
     - ✅ FixSleep Watch Watch App (watchOS)
   - Clique **Add**

### Passo 2: Verificar Arquivos iOS

1. Selecione **FixSleep** (iOS target) no Project Navigator
2. Verifique se os seguintes arquivos estão presentes:
   - ✅ `FixSleepApp.swift`
   - ✅ `ContentView.swift`
   - ✅ `Info.plist`
   - ✅ Pasta `Views/` com 4 arquivos
   - ✅ Pasta `Services/` com 2 arquivos

3. **Verificar Target Membership:**
   - Selecione qualquer arquivo `.swift` no iOS
   - Abra o **File Inspector** (⌥⌘1)
   - Em **Target Membership**, verifique:
     - ✅ FixSleep
     - ❌ FixSleep Watch Watch App (desmarcado)

### Passo 3: Verificar Arquivos watchOS

1. Selecione **FixSleep Watch Watch App** no Project Navigator
2. Verifique se os seguintes arquivos estão presentes:
   - ✅ `FixSleepWatchApp.swift`
   - ✅ `ContentView.swift`
   - ✅ `Info.plist`
   - ✅ Pasta `Views/` com 3 arquivos
   - ✅ Pasta `Services/` com 4 arquivos

3. **Verificar Target Membership:**
   - Selecione qualquer arquivo `.swift` no watchOS
   - Abra o **File Inspector** (⌥⌘1)
   - Em **Target Membership**, verifique:
     - ❌ FixSleep (desmarcado)
     - ✅ FixSleep Watch Watch App

### Passo 4: Verificar Arquivos Shared

Arquivos na pasta `Shared/` devem pertencer a **AMBOS** os targets:

1. Selecione qualquer arquivo em `Shared/` (ex: `AppConfiguration.swift`)
2. No **File Inspector** (⌥⌘1), em **Target Membership**:
   - ✅ FixSleep
   - ✅ FixSleep Watch Watch App

**Importante:** Se algum arquivo Shared não estiver marcado em ambos os targets, marque manualmente.

---

## 🔐 Configurar Capabilities

### Configurar iOS Target

1. Selecione o projeto **FixSleep** no Project Navigator
2. Selecione o target **FixSleep** (iOS)
3. Vá para a aba **Signing & Capabilities**

#### Adicionar HealthKit
1. Clique em **+ Capability**
2. Procure e adicione **HealthKit**
3. Verifique se apareceu a seção **HealthKit** com:
   - Clinical Health Records: ❌ (desmarcado)

#### Adicionar Background Modes
1. Clique em **+ Capability**
2. Procure e adicione **Background Modes**
3. Na seção **Background Modes**, marque:
   - ✅ **Remote notifications**

#### Verificar Info.plist
1. Abra `FixSleep/FixSleep/Info.plist`
2. Confirme que contém:
   ```xml
   <key>NSHealthShareUsageDescription</key>
   <string>FixSleep needs access to your heart rate data...</string>

   <key>NSHealthUpdateUsageDescription</key>
   <string>FixSleep needs permission to record workout sessions...</string>

   <key>NSMotionUsageDescription</key>
   <string>FixSleep uses motion data to filter out false positives...</string>
   ```

### Configurar watchOS Target

1. Selecione o target **FixSleep Watch Watch App** (watchOS)
2. Vá para a aba **Signing & Capabilities**

#### Adicionar HealthKit
1. Clique em **+ Capability**
2. Procure e adicione **HealthKit**

#### Adicionar Background Modes
1. Clique em **+ Capability**
2. Procure e adicione **Background Modes**
3. Na seção **Background Modes**, marque:
   - ✅ **Workout processing**
   - ✅ **Remote notifications** (opcional)

#### Verificar Info.plist
1. Abra `FixSleep/FixSleep Watch Watch App/Info.plist`
2. Confirme que contém:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>workout-processing</string>
   </array>

   <key>WKApplication</key>
   <true/>
   ```

---

## ✍️ Configurar Signing

### Configurar Team (iOS)

1. Selecione o target **FixSleep** (iOS)
2. Na aba **Signing & Capabilities**
3. Em **Signing**, configure:
   - **Automatically manage signing**: ✅ (marcado)
   - **Team**: Selecione sua equipe/conta Apple Developer
   - **Bundle Identifier**: `com.seudominio.FixSleep`
     - Substitua `seudominio` pelo seu Organization Identifier

4. Xcode criará automaticamente um **Provisioning Profile**

### Configurar Team (watchOS)

1. Selecione o target **FixSleep Watch Watch App**
2. Na aba **Signing & Capabilities**
3. Configure da mesma forma:
   - **Automatically manage signing**: ✅
   - **Team**: Mesma equipe do iOS
   - **Bundle Identifier**: `com.seudominio.FixSleep.watchkitapp`

**Nota:** O Bundle ID do watchOS deve ser o do iOS + `.watchkitapp`

### Resolver Erros de Signing

Se aparecer erro **"Failed to register bundle identifier"**:
1. Altere o Bundle ID para algo único (adicione seu nome)
2. Exemplo: `com.seudominio.FixSleep-YourName`
3. Aguarde alguns segundos
4. Xcode sincronizará com o portal Apple Developer

---

## ⚙️ Build Settings

### Configurar Deployment Target

#### iOS Target
1. Selecione target **FixSleep**
2. Aba **Build Settings**
3. Procure **iOS Deployment Target**
4. Configure: **iOS 14.0** (mínimo)

#### watchOS Target
1. Selecione target **FixSleep Watch Watch App**
2. Aba **Build Settings**
3. Procure **watchOS Deployment Target**
4. Configure: **watchOS 7.0** (mínimo)

### Verificar Swift Version

1. Em **Build Settings** (ambos os targets)
2. Procure **Swift Language Version**
3. Configure: **Swift 5** (ou superior)

### Configurar Build Configurations

1. Em **Build Settings**
2. Procure **Optimization Level**
3. Verifique:
   - **Debug**: `-Onone` (sem otimização)
   - **Release**: `-O` (otimização completa)

---

## 🔨 Compilar e Executar

### Build do Projeto

1. Selecione o scheme **FixSleep** na toolbar
2. Escolha um destino:
   - **iPhone 14 Pro** (simulador)
   - Ou seu **iPhone físico** (conectado via cabo)

3. **Build** o projeto:
   - Menu: **Product > Build**
   - Ou: **⌘B**

4. Aguarde a compilação
5. Verifique o **Issue Navigator** (⌘5) para erros

### Resolver Erros Comuns de Build

#### "Cannot find type 'X' in scope"
- **Causa:** Arquivo não adicionado ao target correto
- **Solução:**
  1. Localize o arquivo no Project Navigator
  2. Abra File Inspector (⌥⌘1)
  3. Em Target Membership, marque o target correto

#### "No such module 'HealthKit'"
- **Causa:** HealthKit capability não adicionada
- **Solução:** Veja seção [Configurar Capabilities](#configurar-capabilities)

#### "Undefined symbols for architecture arm64"
- **Causa:** Arquivo não compilado
- **Solução:**
  1. Selecione o target
  2. Aba **Build Phases**
  3. Expanda **Compile Sources**
  4. Verifique se todos os `.swift` estão listados
  5. Se faltam, clique **+** e adicione

### Executar no Simulador

1. Selecione **iPhone 14 Pro** como destino
2. Menu: **Product > Run** (ou **⌘R**)
3. O simulador abrirá e o app iniciará

**⚠️ Limitações do Simulador:**
- HealthKit **não funciona** no simulador
- Você verá mensagens de erro relacionadas ao HealthKit
- Para testar HealthKit, **use um dispositivo físico**

### Executar no Dispositivo Físico

#### Preparar iPhone

1. Conecte o iPhone via cabo USB
2. No iPhone, vá em **Ajustes > Privacidade > Modo de Desenvolvedor**
3. Ative **Modo de Desenvolvedor**
4. Reinicie o iPhone se solicitado
5. Em **Ajustes > Geral > Gestão de Dispositivos**
6. Confie no seu certificado de desenvolvedor

#### Executar App iOS

1. No Xcode, selecione seu **iPhone** como destino
2. Clique **Run** (⌘R)
3. No iPhone, pode aparecer **"Untrusted Developer"**
4. Vá em **Ajustes > Geral > Gestão de Dispositivos**
5. Toque em seu perfil e clique **Confiar**
6. Execute novamente no Xcode

#### Executar App watchOS

1. Certifique-se que o iPhone e Apple Watch estão **pareados**
2. No Watch, ative **Modo de Desenvolvedor**:
   - Abra o app **Watch** no iPhone
   - Vá em **Geral > Modo de Desenvolvedor**
   - Ative e reinicie o Watch

3. No Xcode, selecione scheme **FixSleep Watch Watch App**
4. Escolha seu **Apple Watch** como destino
5. Clique **Run** (⌘R)

**⚠️ Primeira execução pode demorar 5-10 minutos** enquanto o Xcode instala símbolos de debug no Watch.

---

## 🧪 Testes

### Testar Onboarding (iOS)

1. Execute o app iOS no **iPhone físico**
2. Na primeira execução, deve aparecer **OnboardingView**
3. Toque em **"Começar"**
4. O iOS pedirá permissão para:
   - ✅ HealthKit (Heart Rate, HRV)
   - ✅ Notificações
   - ✅ Motion & Fitness
5. Autorize todas as permissões
6. O app deve navegar para o **DashboardView**

### Testar Dashboard (iOS)

1. No **DashboardView**, verifique:
   - ✅ Header com título "FixSleep"
   - ✅ Card "Status de Monitoramento"
   - ✅ Card "Última Leitura de HR"
   - ✅ Card "Eventos de Hoje"
   - ✅ Tabs na parte inferior

2. Navegue entre as tabs:
   - **Dashboard** (🫀)
   - **Eventos** (📋)
   - **Definições** (⚙️)

### Testar Configurações (iOS)

1. Vá para a tab **Definições**
2. Verifique se você pode:
   - ✅ Definir horário de sono (Início/Fim)
   - ✅ Ajustar sensibilidade (Baixa/Média/Alta)
   - ✅ Ativar/desativar alertas
   - ✅ Ver informações sobre permissões

### Testar Monitoramento (watchOS)

1. Execute o app watchOS no **Apple Watch**
2. Na tela principal (**MonitoringView**), verifique:
   - ✅ Botão "Iniciar Monitoramento"
   - ✅ Display de HR atual
   - ✅ Status: "Aguardando..."

3. **Inicie o monitoramento:**
   - Toque em "Iniciar Monitoramento"
   - O app deve solicitar permissão HealthKit (se não foi concedida)
   - Status muda para "Monitorando..."
   - HR atual deve começar a atualizar (ex: "72 BPM")

4. **Pare o monitoramento:**
   - Toque em "Parar Monitoramento"
   - Status volta para "Aguardando..."

### Testar Detecção de Eventos (watchOS)

**Método 1: Teste Manual com Exercício**

1. Inicie o monitoramento no Watch
2. Faça exercício leve (polichinelos, subir escadas)
3. Seu HR deve aumentar rapidamente
4. Quando ultrapassar o threshold (configurado em `AppConfiguration.swift`):
   - ✅ Você deve sentir **haptic feedback** no Watch
   - ✅ Uma notificação deve aparecer
   - ✅ Um evento deve ser registrado

**Método 2: Teste Automático (Debug)**

1. Na view **SettingsView** do Watch
2. Toque em **"Teste de Alerta"** (se implementado)
3. O app simulará um evento
4. Verifique haptic e notificação

### Testar Sincronização Watch ↔ Phone

1. Registre um evento no Watch (via monitoramento)
2. Abra o app iOS
3. Vá para a tab **Eventos**
4. Verifique se o evento aparece na lista

**⚠️ Se não sincronizar:**
- Certifique-se que iPhone e Watch estão **pareados**
- Verifique se o Bluetooth está **ativo**
- Verifique se o WiFi está **ativo** (para transferência rápida)

### Executar Unit Tests

1. Selecione o scheme **FixSleep**
2. Menu: **Product > Test** (ou **⌘U**)
3. Os testes executarão automaticamente
4. Veja os resultados no **Test Navigator** (⌘6)

**Nota:** Os testes atuais são templates. Para implementar testes completos, veja [ARCHITECTURE.md](ARCHITECTURE.md#testing-strategy).

---

## 🐛 Troubleshooting

### Problemas de Build

#### Erro: "Command CompileSwift failed"

**Causa:** Erro de sintaxe no código Swift

**Solução:**
1. Leia a mensagem de erro completa no **Issue Navigator** (⌘5)
2. Clique no erro para ver o arquivo/linha
3. Corrija o erro de sintaxe
4. Build novamente

#### Erro: "Cycle in dependencies"

**Causa:** Dependência circular entre targets

**Solução:**
1. Selecione o target **FixSleep Watch Watch App**
2. Aba **Build Phases**
3. Expanda **Dependencies**
4. **Remova** qualquer dependência do target iOS
5. Clean Build Folder (⌘⇧K)
6. Build novamente

#### Erro: "Library not found for -lswiftXYZ"

**Causa:** Framework Swift não vinculado

**Solução:**
1. Aba **Build Settings**
2. Procure **Always Embed Swift Standard Libraries**
3. Configure para **Yes**
4. Clean e rebuild

### Problemas de Runtime

#### App crasha ao iniciar (iOS)

**Verificar:**
1. Abra o **Console** (Xcode > Window > Devices and Simulators)
2. Selecione seu iPhone
3. Clique em **Console**
4. Execute o app novamente
5. Procure por mensagens de erro

**Causas comuns:**
- Info.plist faltando permissões
- Arquivo de código não compilado
- Crash no `AppDelegate` ou `@main`

#### App crasha ao acessar HealthKit

**Erro:** `"This app has crashed because it attempted to access privacy-sensitive data..."`

**Solução:**
1. Verifique se `Info.plist` contém:
   - `NSHealthShareUsageDescription`
   - `NSHealthUpdateUsageDescription`
2. Adicione as strings se faltarem
3. Reinstale o app

#### HealthKit retorna "Not available"

**Causa:** HealthKit não está disponível no simulador

**Solução:**
- **Use um dispositivo físico** para testar HealthKit

#### Watch app não instala no Apple Watch

**Verificar:**
1. iPhone e Watch estão **pareados**
2. Watch está **desbloqueado**
3. Watch tem **espaço suficiente** (mínimo 500 MB)
4. Em **Devices and Simulators**, verifique se o Watch aparece
5. Reinicie o Watch e tente novamente

#### Monitoramento não inicia (watchOS)

**Verificar:**
1. HealthKit está **autorizado**
2. Watch está **no pulso** (sensor precisa detectar pele)
3. Watch está **desbloqueado**
4. Verifique logs no Console

### Problemas de Sincronização

#### WatchConnectivity não funciona

**Verificar:**
1. Ambos os apps estão **instalados** (iOS e watchOS)
2. iPhone e Watch estão **pareados**
3. Bluetooth está **ativo** em ambos
4. Wi-Fi está **ativo** (para transferências grandes)

**Debug:**
1. Adicione logs em `WatchConnectivityManager.swift`:
   ```swift
   print("WCSession isReachable: \(session.isReachable)")
   print("WCSession activationState: \(session.activationState.rawValue)")
   ```
2. Execute e verifique no Console

#### Eventos não aparecem no iPhone

**Verificar:**
1. `WatchConnectivityManager.shared.activate()` é chamado no `AppDelegate`
2. `DataManager.shared.addEvent()` é chamado ao detectar evento
3. Watch está conectado e com app iOS aberto

### Problemas de Permissões

#### HealthKit sempre pede permissão

**Causa:** App foi reinstalado ou permissões revogadas

**Solução:**
- Na primeira execução, isso é normal
- Em execuções subsequentes, verifique `HealthKitManager.isAuthorized`

#### Notificações não aparecem

**Verificar:**
1. Permissão de notificações foi **concedida**
2. No iPhone: **Ajustes > Notificações > FixSleep** > **Permitir Notificações** ✅
3. No código, `NotificationManager.requestAuthorization()` é chamado

### Problemas de Performance

#### App muito lento no Watch

**Possíveis causas:**
1. Monitoramento HR com sampling rate muito alto
2. Muitas animações/views complexas
3. Processamento pesado na main thread

**Otimizações:**
1. Em `AppConfiguration.swift`, aumente `heartRateSamplingInterval`
2. Use `DispatchQueue.global()` para processamento pesado
3. Simplifique views (remova sombras/gradientes complexos)

#### Bateria drena rápido

**Verificar:**
1. Monitoramento está **ativo 24/7**? Deve estar apenas no sleep window
2. Sampling rate muito alto
3. Background fetch muito frequente

**Otimizações:**
1. Ative monitoramento apenas durante o horário de sono
2. Aumente `heartRateSamplingInterval` para 5-10 segundos
3. Implemente power-saving mode (ver `AppConfiguration.swift`)

---

## 🎯 Próximos Passos

Após configurar com sucesso, você pode:

### 1. Calibrar Thresholds

Edite `FixSleep/Shared/Configuration/AppConfiguration.swift`:

```swift
// Ajuste os valores conforme sua fisiologia
static let absoluteHRThreshold: Double = 80  // BPM mínimo para detecção
static let relativeHRDeltaThreshold: Double = 15  // Aumento em BPM
static let hrvDropThreshold: Double = 0.3  // Queda de 30% em HRV
```

**Como calibrar:**
1. Execute o app por 3-5 noites
2. Analise os eventos registrados
3. Se muitos **falsos positivos** → aumente thresholds
4. Se **poucos eventos** detectados → diminua thresholds

### 2. Personalizar UI/Tema

Edite `FixSleep/Shared/Theme/AppTheme.swift`:

```swift
// Altere cores
enum Primary {
    static let deepPurple = Color(hex: "5B4B8A")  // Cor primária
    // ...
}
```

### 3. Adicionar App Icons

1. Crie ícones em todas as resoluções necessárias:
   - iOS: 1024×1024 (App Store), 60×60, 76×76, etc.
   - watchOS: 1024×1024, 44×44, 48×48, etc.

2. No Xcode, abra **Assets.xcassets**
3. Clique em **AppIcon**
4. Arraste seus ícones para os slots corretos

**Ferramentas recomendadas:**
- [App Icon Generator](https://appicon.co)
- [IconKitchen](https://icon.kitchen)

### 4. Implementar Funcionalidades Avançadas

#### Machine Learning para Detecção
- Treine um modelo CoreML com dados de HR/HRV
- Integre em `DetectionEngine.swift`

#### CloudKit Sync
- Adicione CloudKit capability
- Implemente sync de eventos e settings
- Veja [CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)

#### Complications (watchOS)
- Adicione complication para mostrar status no watch face
- Implemente `CLKComplicationDataSource`

#### Widgets (iOS)
- Crie widget para Dashboard com WidgetKit
- Mostre eventos recentes na tela inicial

### 5. Preparar para App Store

#### Privacy Policy
- Crie uma política de privacidade
- Hospede em URL pública
- Atualize `Info.plist`:
  ```xml
  <key>NSPrivacyPolicyURL</key>
  <string>https://seusite.com/privacy</string>
  ```

#### App Store Metadata
- Screenshots (iPhone: 6.5", 5.5"; Watch: 40mm, 44mm)
- Descrição do app (português e inglês)
- Keywords para SEO
- Categoria: **Saúde e Fitness**

#### Compliance
- **HealthKit apps não podem ter publicidade**
- **Não é dispositivo médico** - adicione disclaimer
- Veja [App Store Review Guidelines - HealthKit](https://developer.apple.com/app-store/review/guidelines/#health-and-health-research)

#### Submissão
1. Archive o app: **Product > Archive**
2. Abra **Organizer** (Window > Organizer)
3. Clique **Distribute App**
4. Escolha **App Store Connect**
5. Siga o wizard de upload

### 6. Monitoramento e Analytics

Adicione ferramentas para entender uso:

#### Firebase Analytics (opcional)
```swift
// Rastreie eventos
Analytics.logEvent("monitoring_started", parameters: nil)
```

#### Crash Reporting
- Firebase Crashlytics
- Sentry
- Apple Crash Reports (automático)

---

## 📚 Recursos Adicionais

### Documentação Apple

- [HealthKit Framework](https://developer.apple.com/documentation/healthkit)
- [WatchKit](https://developer.apple.com/documentation/watchkit)
- [WatchConnectivity](https://developer.apple.com/documentation/watchconnectivity)
- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Tutoriais e Guias

- [Developing HealthKit Apps (WWDC)](https://developer.apple.com/videos/play/wwdc2020/10664/)
- [Building watchOS Apps (WWDC)](https://developer.apple.com/videos/play/wwdc2021/10002/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### Comunidade

- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Stack Overflow - HealthKit](https://stackoverflow.com/questions/tagged/healthkit)
- [r/iOSProgramming](https://reddit.com/r/iOSProgramming)
- [Swift Forums](https://forums.swift.org)

### Arquivos do Projeto

- [CLAUDE.md](CLAUDE.md) - Visão geral do projeto
- [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitetura técnica detalhada
- [DESIGN.md](DESIGN.md) - Design e UX guidelines

---

## 💡 Dicas de Desenvolvimento

### Atalhos Úteis do Xcode

| Atalho | Ação |
|--------|------|
| ⌘B | Build |
| ⌘R | Run |
| ⌘. | Stop |
| ⌘⇧K | Clean Build Folder |
| ⌘⇧O | Open Quickly (buscar arquivos) |
| ⌘⌥[ | Move linha para cima |
| ⌘⌥] | Move linha para baixo |
| ⌘/ | Comentar/descomentar |
| ⌘⇧F | Find in Project |
| ⌘1-9 | Alternar entre navigators |

### Debug Eficiente

#### Print Statements
```swift
print("❤️ HR Monitor - Current HR: \(heartRate) BPM")
print("⚠️ Detection Engine - Event detected!")
print("✅ WatchConnectivity - Message sent successfully")
```

Use emojis para identificar rapidamente no console.

#### Breakpoints
1. Clique na margem esquerda do editor (número da linha)
2. Execute em modo debug (⌘R)
3. O app pausará no breakpoint
4. Use **Debug Area** para inspecionar variáveis

#### View Debugging
1. Execute o app
2. Menu: **Debug > View Debugging > Capture View Hierarchy**
3. Inspecione a hierarquia 3D de views

### Git Workflow

```bash
# Criar branch para feature
git checkout -b feature/nome-da-feature

# Fazer commits frequentes
git add .
git commit -m "Implementa detecção avançada de eventos"

# Push para remote
git push origin feature/nome-da-feature

# Criar Pull Request no GitHub
```

### Boas Práticas

1. **Commits pequenos e frequentes** - mais fácil de debugar
2. **Mensagens descritivas** - explique o "porquê", não o "o quê"
3. **Code Review** - peça feedback antes de merge
4. **Testes** - escreva testes para lógica crítica
5. **Documentação** - comente código complexo

---

## ❓ Suporte

Se encontrar problemas não cobertos neste guia:

1. **Verifique os logs** no Console (Devices and Simulators)
2. **Consulte ARCHITECTURE.md** para detalhes técnicos
3. **Abra um issue** no GitHub com:
   - Descrição do problema
   - Passos para reproduzir
   - Screenshots/logs
   - Versão do Xcode e macOS

---

**Boa sorte com o desenvolvimento! 🚀**

Criado por Filipe Marques | Atualizado em 06/12/2025
