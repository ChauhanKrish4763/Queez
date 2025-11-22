# Design Document

## Overview

The Live Multiplayer Mode implements a real-time, synchronous quiz gameplay system using WebSocket-based bidirectional communication between Flutter clients and a Python FastAPI backend. The architecture follows an authoritative server pattern where all game state, scoring, and validation occur server-side to prevent cheating and ensure consistency across all participants.

The system supports the complete lifecycle of a multiplayer session: session creation with unique codes, participant joining through a waiting lobby, synchronized question presentation with countdown timers, real-time answer submission and scoring, live leaderboard updates, and final results display. The design prioritizes low-latency communication, automatic reconnection handling, and graceful degradation under network issues.

## Architecture

### High-Level Architecture

```
┌─────────────────┐         WebSocket          ┌─────────────────┐
│  Flutter Client │◄──────────────────────────►│  FastAPI Server │
│   (Host/Player) │         (wss://)           │   (Authoritative)│
└─────────────────┘                            └─────────────────┘
                                                        │
                                                        ▼
                                                ┌───────────────┐
                                                │  Redis Cache  │
                                                │  - Sessions   │
                                                │  - Leaderboard│
                                                └───────────────┘
                                                        │
                                                        ▼
                                                ┌───────────────┐
                                                │   MongoDB     │
                                                │  - Quizzes    │
                                                │  - Results    │
                                                └───────────────┘
```

### Communication Protocol

- **Transport**: WebSocket (wss://) for persistent bidirectional communication
- **Serialization**: JSON for message encoding (human-readable, easy debugging)
- **Message Structure**: All messages include `type`, `payload`, and optional `sequence_number`
- **Heartbeat**: Ping/pong every 30 seconds to detect disconnections

### State Management

**Server-Side (Authoritative)**:
- Redis stores active session state (participants, current question, scores)
- MongoDB stores persistent data (quiz content, final results)
- Server validates all actions and broadcasts state changes

**Client-Side (Reactive)**:
- Flutter Riverpod for state management
- WebSocket stream triggers state updates via providers
- UI rebuilds reactively on state changes using ConsumerWidget
- Local state for UI-only concerns (animations, transitions)

## Components and Interfaces

### Backend Components

#### 1. WebSocket Connection Manager

**Responsibility**: Manage WebSocket connections, routing, and broadcasting

```python
class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}
    
    async def connect(self, websocket: WebSocket, session_code: str, user_id: str)
    async def disconnect(self, session_code: str, user_id: str)
    async def send_personal_message(self, message: dict, websocket: WebSocket)
    async def broadcast_to_session(self, message: dict, session_code: str)
    async def broadcast_except(self, message: dict, session_code: str, exclude_user: str)
```

#### 2. Session Manager

**Responsibility**: Handle session lifecycle and state transitions

```python
class SessionManager:
    def __init__(self, redis_client, mongo_client):
        self.redis = redis_client
        self.mongo = mongo_client
    
    async def create_session(self, quiz_id: str, host_id: str) -> str
    async def get_session(self, session_code: str) -> SessionState
    async def add_participant(self, session_code: str, user_id: str, username: str)
    async def remove_participant(self, session_code: str, user_id: str)
    async def start_session(self, session_code: str, host_id: str)
    async def end_session(self, session_code: str)
    async def is_host(self, session_code: str, user_id: str) -> bool
```

#### 3. Game Controller

**Responsibility**: Manage quiz gameplay logic and progression

```python
class GameController:
    async def advance_question(self, session_code: str)
    async def submit_answer(self, session_code: str, user_id: str, answer: Any, timestamp: float)
    async def calculate_score(self, is_correct: bool, response_time: float) -> int
    async def check_all_answered(self, session_code: str) -> bool
    async def reveal_answer(self, session_code: str)
    async def get_current_question(self, session_code: str) -> Question
```

#### 4. Leaderboard Manager

**Responsibility**: Maintain and update real-time rankings

```python
class LeaderboardManager:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    async def update_score(self, session_code: str, user_id: str, points: int)
    async def get_rankings(self, session_code: str, limit: int = 10) -> List[Ranking]
    async def get_user_rank(self, session_code: str, user_id: str) -> int
    async def clear_leaderboard(self, session_code: str)
```

### Frontend Components

#### 1. WebSocket Service

**Responsibility**: Manage WebSocket connection and message handling

```dart
class WebSocketService {
  IOWebSocketChannel? _channel;
  StreamController<Map<String, dynamic>> _messageController;
  
  Future<void> connect(String sessionCode, String userId);
  void disconnect();
  void sendMessage(Map<String, dynamic> message);
  Stream<Map<String, dynamic>> get messageStream;
  Future<void> reconnect();
}
```

#### 2. Session State Notifier

**Responsibility**: Manage session state and business logic

```dart
class SessionState {
  final String? sessionCode;
  final SessionStatus status;
  final List<Participant> participants;
  final bool isHost;
  final String? errorMessage;
  
  SessionState({
    this.sessionCode,
    required this.status,
    this.participants = const [],
    this.isHost = false,
    this.errorMessage,
  });
}

class SessionNotifier extends StateNotifier<SessionState> {
  final WebSocketService _wsService;
  
  SessionNotifier(this._wsService) : super(SessionState(status: SessionStatus.initial));
  
  Future<void> joinSession(String sessionCode, String userId, String username);
  Future<void> startSession();
  void handleMessage(Map<String, dynamic> message);
  void handleDisconnection();
}

// Provider
final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return SessionNotifier(wsService);
});
```

#### 3. Game State Notifier

**Responsibility**: Manage gameplay state and answer submission

```dart
class GameState {
  final QuizQuestion? currentQuestion;
  final int questionIndex;
  final int totalQuestions;
  final int timeRemaining;
  final bool hasAnswered;
  final bool? isCorrect;
  final int? pointsEarned;
  
  GameState({
    this.currentQuestion,
    this.questionIndex = 0,
    this.totalQuestions = 0,
    this.timeRemaining = 30,
    this.hasAnswered = false,
    this.isCorrect,
    this.pointsEarned,
  });
}

class GameNotifier extends StateNotifier<GameState> {
  final WebSocketService _wsService;
  Timer? _timer;
  
  GameNotifier(this._wsService) : super(GameState());
  
  void handleQuestionReceived(Map<String, dynamic> data);
  Future<void> submitAnswer(dynamic answer);
  void startTimer(int duration);
  void stopTimer();
  void handleAnswerRevealed(Map<String, dynamic> data);
}

// Provider
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  return GameNotifier(wsService);
});
```

#### 4. Leaderboard State Notifier

**Responsibility**: Manage leaderboard state and updates

```dart
class LeaderboardState {
  final List<LeaderboardEntry> rankings;
  final int? yourRank;
  final int? yourScore;
  
  LeaderboardState({
    this.rankings = const [],
    this.yourRank,
    this.yourScore,
  });
}

class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  LeaderboardNotifier() : super(LeaderboardState());
  
  void updateLeaderboard(List<LeaderboardEntry> rankings, int yourRank);
  void updateScore(int score);
}

// Provider
final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
  return LeaderboardNotifier();
});
```

## Data Models

### Session State (Redis)

```python
{
  "session_code": "ABC123",
  "quiz_id": "quiz_uuid",
  "host_id": "user_uuid",
  "status": "waiting|active|completed",
  "current_question_index": 0,
  "question_start_time": 1234567890.123,
  "participants": {
    "user_uuid": {
      "user_id": "user_uuid",
      "username": "player1",
      "connected": true,
      "score": 0,
      "answers": [
        {
          "question_index": 0,
          "answer": 2,
          "timestamp": 1234567890.456,
          "is_correct": true,
          "points_earned": 1350
        }
      ]
    }
  },
  "created_at": "2024-01-01T00:00:00Z",
  "expires_at": "2024-01-02T00:00:00Z"
}
```

### WebSocket Message Types

**Client → Server**:
```typescript
// Join session
{ type: "join", payload: { session_code: string, user_id: string, username: string } }

// Submit answer
{ type: "submit_answer", payload: { answer: any, timestamp: number } }

// Start quiz (host only)
{ type: "start_quiz", payload: {} }

// End quiz (host only)
{ type: "end_quiz", payload: {} }

// Heartbeat
{ type: "ping", payload: {} }
```

**Server → Client**:
```typescript
// Session state update
{ type: "session_update", payload: { status: string, participant_count: number, participants: [] } }

// Question display
{ type: "question", payload: { question: Question, index: number, total: number, timer: 30 } }

// Answer result
{ type: "answer_result", payload: { is_correct: boolean, correct_answer: any, points_earned: number } }

// Leaderboard update
{ type: "leaderboard", payload: { rankings: [], your_rank: number } }

// Quiz completed
{ type: "quiz_completed", payload: { final_rankings: [], winner: {}, your_stats: {} } }

// Error
{ type: "error", payload: { message: string, code: string } }

// Heartbeat response
{ type: "pong", payload: {} }
```

### Participant Model

```dart
class Participant {
  final String userId;
  final String username;
  final int score;
  final bool isConnected;
  final bool isHost;
  final int rank;
  final int correctAnswers;
  final int totalAnswers;
  
  double get accuracy => totalAnswers > 0 ? correctAnswers / totalAnswers : 0.0;
}
```

### Question Model (Extended)

```dart
class QuizQuestion {
  final String id;
  final String questionText;
  final QuestionType type;
  final List<String> options;
  final dynamic correctAnswer;
  final int timeLimit; // seconds
  final String? imageUrl;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Session Creation Properties

Property 1: Unique session code generation
*For any* quiz, creating a session should produce a 6-character alphanumeric code that is unique across all active sessions
**Validates: Requirements 1.1**

Property 2: Session expiration invariant
*For any* newly created session, the expiration time should be exactly 24 hours from the creation timestamp
**Validates: Requirements 1.3**

Property 3: Initial session state
*For any* newly created session, the game state status should be "waiting"
**Validates: Requirements 1.4**

### Participant Management Properties

Property 4: Join increases participant count
*For any* session in waiting status and any valid participant, joining should increase the participant count by exactly 1
**Validates: Requirements 2.2**

Property 5: Join triggers broadcast
*For any* session with multiple connected clients, when a participant joins, all connected clients should receive a session update message
**Validates: Requirements 2.3, 3.1**

Property 6: Started sessions reject joins
*For any* session with status "active" or "completed", join attempts should be rejected with an error
**Validates: Requirements 2.5, 4.4**

Property 7: Join sends current state
*For any* participant who successfully joins a session, they should receive a message containing the current game state
**Validates: Requirements 2.6**

Property 8: Participant data completeness
*For any* participant in a session, their data should include username and join timestamp fields
**Validates: Requirements 3.2**

Property 9: Disconnect marks participant
*For any* connected participant, disconnecting should set their connected status to false in the participant list
**Validates: Requirements 3.4**

Property 10: Reconnection window restoration
*For any* participant who disconnects and reconnects within 60 seconds, their participant status and score should be restored
**Validates: Requirements 3.5, 10.2**

### Quiz Start Properties

Property 11: Minimum participant validation
*For any* session, attempting to start with fewer than 2 connected participants should be rejected
**Validates: Requirements 4.1**

Property 12: Start transitions state
*For any* session in "waiting" status, starting the quiz should transition the status to "active"
**Validates: Requirements 4.2**

Property 13: Start broadcasts first question
*For any* session with multiple participants, starting the quiz should send the first question to all participants
**Validates: Requirements 4.3**

Property 14: Question timer initialization
*For any* question displayed, the system should initialize a timer counting down from 30 seconds
**Validates: Requirements 4.5, 5.1**

### Answer Submission Properties

Property 15: Answer timestamp recording
*For any* submitted answer, the answer record should contain a timestamp field
**Validates: Requirements 5.2**

Property 16: Answer validation correctness
*For any* submitted answer, the system should return is_correct=true if the answer matches the correct answer, and is_correct=false otherwise
**Validates: Requirements 5.3**csAnalyti
7. **iz sessionsd replay que an Sav*:*Replay*ting
6. *ticipawithout par sessions rs to watch*: Allow user Mode*tatopec**Sd
5. aggregate are and scoreseams  tormrticipants f**: Pa ModeTeamc.)
4. **50/50, etmer,  tizefrees can use (antarticipabilities ppecial wer-ups**: S **Po
3.imitstion time lure ques config hosts tollow: Aer**stom Timz
2. **Cu during quicationommunie cC for voic WebRTgratet**: Intece Cha**Voi

1. ementshancture En# Fu0
```

#DS=6ECONN_TIMEOUT_SONNECTIORECL=30
VATERET_PING_INEBSOCKON=50
WTS_PER_SESSIIPAN
MAX_PARTICS=5NDVEAL_SECOWER_RE
ANS_SECONDS=30ON_TIMERS=24
QUESTI_EXPIRY_HOUR
SESSIONecret_key>ET=<sCR
JWT_SEost:27017db://localhB_URL=mongoOD6379
MONGost:lh//locaS_URL=redis:
REDI
```ariables**:ent VronmEnvion

**ti Configura###> 80%

age  user CPU- Serv> 80%
mory usage 
- Redis me5 > 200ms latency p9
- Messageor rate > 5%errection ocket conns**:
- WebSrtAle

**age memory usndrver CPU aSeance
- ry performngoDB quee
- Moory usagedis mem p99)
- Ry (p50, p95,latencsage - Mes errors
t connection- WebSockent
pants couted partici- Conneccount
sessions ive :
- Actck**racs to Tg

**Metriitorin Mon###

assetsor static DN f Csessions
-y with stickcer d balan loacketase
- WebSor databas fo MongoDB Atlloud)
-edis Ce, R ElastiCachservice (AWSd nage
- Redis maAzure)CP/rm (AWS/Gd platfoclouon I deployed stAP:
- Faoduction**
**Prt
lhoscts to loca app conne Flutterce
-oDB instan Local Mongce
-edis instanLocal Rorn
-  uvicwithrver stAPI secal Fat**:
- Lopmen
**Develoure
ruct## Infrastns

#sideratioloyment Con Depcation

##unicommn for all ncryptioSS es
- HTTPS/Wss sessioncking acro trastent userrsion
- No pee sessiared outsidt shnames) no data (usersonalPerurs
- after 24 holeted n data dessiocy

- Sea Priva
### Datr client)
econd pe10/smax t messages (WebSocken ting o- Rate limigged
ms) fla(< 100imes se tsponle re
- Impossibs rejectedonbmissisucate answer Dupli
- nst timerd agai validatesionsnswer submis-side
- A serveredrmerfoculations pal scoring cs

- Allureasat MeAnti-Che### e)

ancecond toler±5 s (erver timet sinsagalidated amps: vamest type
- Tiestiond against qu validatealues:nswer v Aes
-spacric + phanumearacters, al 3-20 ch Usernames:
-nlyharacters oic cer 6 alphanumn codes:
- Sessio
Validationt ### Inpud users

uthorizefrom unacts actions rver reje Se actions
-ipantr all partic_id foerlidates userver vaions
- Sl host actor al_id fes hostrver validat- Se
tion
oriza# Authrs

##r 24 houe aftens expiron
- Tokeconnectie accepting for token bedates vali
- Serversagel mesnitiaor ition URL t connec in WebSockecluded inention
- TokenticaauthbSocket kens for We toJWTcation

- ### Authentiions

Considerat Security )

##eveal phase rngestion duriend next qung (sadition pre-loges)
- Quesal messaindividu (not  updates participant
- Batchranks)changed y nlard (or leaderbo foes Delta updatayloads
-e p for largip) (gzressionssage compMezation

- th Optimiwid
### Band state
or session cluster fedishared R server
- Sstay on samerticipants ensure passions icky seons
- St connecticketebSotes Wer distribud balanc Loaing
-astadc brover message cross-serub fordis Pub/S:
- Reture)ling** (Furizontal Sca)

**Hoblockingync, non-e (assistenc handles perngoDBst)
- Mo-memory, fa(insion state  sesdis handless
- Reonnectionocket cent WebSncurr
- 10,000 cosessionsnt 000 concurre 1rget:
- Ta: Capacity**Servere Singlbility

**

### Scala< 30msing: cesson proubmissi Answer sms
-ion: < 50 calculatdated up Leaderboar
-ts: < 200msicipanall part to broadcastion - Quests (p95)
ip: < 100me round-trcket messag WebSoTargets

-ncy ### Lateons

ideratince Cons## Performauption

terrk in networfternnection actly
- Recorey cor displaults- Final resy
correctltes rd updaeaderboa- Luestions
s qsweroins and an jParticipantquiz
- starts ion and s sessHost createests):
- ration tutter integ** (Flestsomated E2E Ting

**Auto-End Test-t
### Endlication
 dupsage loss oro mesVerify nusage
- y PU and memorure C
- Meas p95)t: < 100msrgey (tancssage latere me
- Measuants each0 participons with 1nt sessiurreonc
- 100 c**: Testing*Loadires

*mer exp ting beforets answeriipanicAll partswers
-  no anxpiry with- Timer e
quiz earlyding  Host enreconnect
-onnect and ant disc
- Participltaneouslyg simujoininticipants ultiple par
- Momplete)y → ct → platare → join → screatycle (sion lifecFull sesTests**:
- ntegration t IckeSo

**Webion Testingrat## Integceed

#ucctions sonly host aify  Veroth
   -ith bions wmpt host act
   - Atte)nd non-host ahostuser IDs (andom nerate r Ge
   -, 45):rties 39 (Propeorization****Authstate

5. ected tches expng state mafy resultis
   - Veriion action transittate  - Apply stes
  sta variousons innerate sessi - Ge):
   12, 32, 40s 3,ie (Propertons**ansititate Tr4. **Sy 1

by exactlcreased fy count in - Veripant
  a partici - Add nts
  ticipant coutial par random ininerate- Gey 4):
   ** (Propertpant Count. **Particiore 0

3rs always scsweect an incorr   - Verifyonds
 30 sec to 0 overm 500early froinases lcrebonus deme Verify ti- 
   base pointsclude 1000 rs always inect answeorr  - Verify ctimes
 nd response lues aness vaorrectndom c ra  - Generate 20, 21):
 rtiespen** (Proculatio Cal
2. **Scorephanumeric
alers  6 charactl codes areVerify al  - 
 re uniquesion codes arify all sess
   - Vesion sesGenerate N   - rty 1):
s** (Propeniqueneson Code U
1. **Sessis**:
leest Examp**Property Ts.

putgenerated indomly ranwith iterations 100  minimum of run at will y-based tesertg. Each proptestinperty-based ckend prohon) for ba (Pyt**ypothesisll use **Htem wi
The sysed Testing
-Bas# Property
## sorting
derboardtting
- Lealay formadispScore c
- own logiTimer countd
- itions trans BLoC stateg
-e parsinet messagebSock
- Wer_test):* (fluttsts* Unit Te**Frontend

hecksrization cAuthondling
- iry haTimer expgic
- lidation lor vawe
- Ansnsitionson state tra
- Sessing algorithm rankierboard
- Lead time bonus) (base +n logiclculatioore cas
- Sces uniquene generationcodon 
- Sessiest):ts** (pytnd Unit Tes**Backeng

Testi## Unit y

#trategg S## Testin

"ntials.credevalid host : "InHOST`INVALID_on."
- ` this actirform can pehosty the `: "OnlUTHORIZEDNOT_A `**:
-gesrror Message

**Essar melays erro Client disp error
3.nsrver returd, serize autho. If not
2sion host_id sesr_id matchesuseng questilidates reerver va*:
1. Sg*dlinHant action
**empts hosost atto**: Non-hnarice
**Srors
n Erzatio
### Authori"
format.d answer `: "InvaliVALID_ANSWERIN."
- `stionis quenswered thve already a"You haRED`: ANSWEY_"
- `ALREADorded.recwer was not  Your ans"Time's up!O_LATE`: - `ANSWER_TOsages**:
 Mes

**Erroror toastys brief errnt displa)
5. Clienect disconsn'tbut doe error (turnser res, servion failalidat
4. If vreddy answe alreahasn'tparticipant rver checks  type
3. Se question matchesatorm fdates answeralirver v. Sen timer
2nst questiop agaion timestams submissiateServer validling**:
1. sion
**Handte submis or lad answer*: Invali*Scenario*rs

*Errosion Submis# Answer ."

##n is fullis sessio "Th_FULL`:
- `SESSIONarted."sthas already iz `: "This quTEDTARON_ALREADY_S
- `SESSId."expiren has  sessio"ThisXPIRED`:  `SESSION_Egain."
-d try aande he cok tece chPleasound. ssion not fFOUND`: "Se_NOT_ `SESSIONages**:
-Messrror 

**Eno join screereturns tsage and or mesays err displ4. Clientnse
respos error returnver serpired, d or exali
3. If invn timestampratiossion expir checks seerve S Redis
2.e exists inn codates sessioid val
1. Serverling**:**Handsion
pired ses code or exond sessiio**: Invalinar
**Sces
sion Error## Ses

#". has expiredessionD`: "This sION_EXPIRE
- `SESSon."net connecti interourse check yt. Plea to reconnecnableLED`: "UCTION_FAIONNE"
- `RECnecting... Reconon lost."ConnectiLOST`: CTION_ONNE**:
- `Ces Messagrrorbby

**Eto loxits  and eroron lost" er "Connectint displaysieclseconds, ls after 60 ection faiconnnt
7. If reclied o reconnectestate tame  gs currentr sendve
6. Ser stateticipantes pare and restortill activion is ss sessalidatever vSer5. ode
session_cd and er_ih usit wt messageonnecnt sends recection, clieeconnccessful rsu4. On 0s (max)
, 16s, 3 2s, 4s, 8s: 0s, 1s,offtial backwith exponenon ctimpts reconnent atteng)
3. Clieockiblon-overlay (n" cting...ys "Reconneispla
2. Client ding timeoutt or pse evenn clonnectiogh coction throudisconneects ient detg**:
1. Cls
**Handlinails or dropn f connectioebSocketcenario**: Wrors

**Sion Er## Connectng

#ror Handli# Er12.4**

#uirements tes: Reqdast
**Valion hohe sessiser is not trequesting uf the  rejected ist should be the reque, end),rttion (stast-only acFor any* hoion
*horizat autst actionrty 45: Hope
Pro, 12.2**
12.1uirements es: Req*Validated
*jecthould be remission s, the suber expirytimion ueste qter this aftimestamp submission n, if the missio sub any* answer
*Forationidmp val 44: Timestaopertyes

Pr Propertiurityec

### Sents 11.5**equiremValidates: Rd
**e displayeults ar after resbe closedd s shoulnectionconet ockbSWeiz, all ed qu* complet
*For anyonr completite cleanup afon3: Connectiroperty 411.4**

Pts uiremenidates: ReqValts
**ticipan to all pardcastbe broats should  resulfinalarly, iz ended eor any* qu results
*Fn broadcastsrminatio: Early tey 42
Propertnts 11.3**
equiremelidates: Rered
**Va answat wereions th quested only onbasalculated ould be cres shal sco finded early,any* quiz enring
*For artial scormination pEarly tety 41: operPr
*
s 11.2*uirementates: Req
**Valid"pletedn to "comnsitiold tra status shou early, thends the quizst een the hoion, whessny* s
*For ans stateioansition trrly terminatEaoperty 40: Pr

nts 11.1**reme Requi*Validates:t
*on host the sessig user is nostineque rthed if d be rejectehoulequest, it sination rarly termor any* e
*Frminationon for teuthorizatist a Hoerty 39:s

Propertietrol Prop Con

### Host0.4**nts 1uiremeidates: Reqect
**Valrrs inco arkedshould be mans red questioanswemaining unds, all reconn 60 seor more thannected fcot disicipan* partty
*For anyction penalsconnedi8: Long y 3rtrope 10.3**

Pirements Requs:*Validate
*stateand game n ent questio the curreiverecey should ts, thneconeco rt whicipany* partor anync
*Fe saton stnnectico Rerty 37:ropeies

PPropertn ectionn# Reco
##
ments 9.6** Requireates:lid
**Vasethe databarsisted to ould be pe sh resultsionhe sessquiz, tompleted * cor any
*Fstences persi 36: Resulterty

Prop*ements 9.5*equirates: R
**Validons)ered questial answ/ totanswers rect al (cord equracy shoulcu acirlts, thesunal re fit inticipanr any* parlation
*Focuracy calcuerty 35: Acrop**

P.3ements 9es: Requirdat
**Valisipanticrtpa top 10 thehow at most t should say, ipllts dis* final resuFor any
*ant limitipts partic Final resul4:rty 3rope**

Prements 9.2: Requi
**Validatespantsticir all parulated fobe calc should nal rankings quiz, ficompleted
*For any* ankingsfinal rtes on calcula: Completiy 33ert1**

Prop9.ments  Requirealidates:leted"
**Von to "compnsitiould tras sh statuame stateered, the ganswquestion is the last  where sionny* sesFor as state
* transitiontionon comple questinal 32: Fity

ProperrtiesPropeon Completiz # Qui
##5**
ements 8.es: Requir*Validat
*rrectlyswered cocipant anat partiher thicate whethould indnt, it sparticipa sent to a eal messagenswer rev*For any* aeedback
ctness fcorrel sonaty 31: Per
Proper8.4**
uirements ates: Reqidalion
**Vstthe next quecing to re advandelay befo5-second  be a here should, tveal reeransw* For any
*ing delayim Reveal trty 30:

Propements 8.3**quireates: Re**Validion
ch opt selected eaants who of participde the countlud incshoulmessage, it eal r revany* answe
*For icstion statistibuistrswer dperty 29: An2**

Pro 8.quirementsidates: Realue
**Valect answer v corr thentainhould cosage, it seveal mesr ry* answer an
*Foect answercorrins ge contasa Reveal mes28:
Property nts 8.1**
emeRequir*Validates: 
*pireshe timer ex OR twered have ansntsicipal partither aln ealed wheevee rshould banswer rect he coron, tuesti any* q*For triggers
er revealty 27: AnswProperrties

eal PropeAnswer Rev### 

4**nts 7.emetes: Requirlida
**Vaon messagestixt quenethe nt before should be see ssag meard updateaderbolee n, thioleted questny* compFor aion
*stnext que before erboardead L26:

Property nts 7.3**s: Requireme**Validaterankings
 updated receive thehould ants s participallate, rboard updany* leader  update
*Fost onoadcaboard bradery 25: Le*

Propert 7.2*irements Requlidates:*Vae fields
*al scorotname, and tser rank, ucontaint should entry, iderboard For any* leass
*pletenerd data comrboaLeade: operty 24ies

Prrtrboard Propeade### Le7.1**

ts 6.5, quiremen Realidates: scores
**Vect the newreflulated to ld be recalcouings shard rankeaderbo the lhange,re cr any* scoange
*Fochon on score tialculaboard recder 23: Lea

Propertyements 6.4** Requirates:Validssage
**ate mere upd a scoivehould recearticipant sat phanges, the score cpant whos partici
*For any*roadcastate bpd 22: Score uoperty**

Prements 6.3 Requirates:**Validnds
co 30 seoints atd 0 presponses anate  immedis forpointf 500 mum oaxi with a mime bonuses,rn higher tuld ease times shoter responn, fasr submissioy* answeor an
*Fculationonus cal Time berty 21:
Propnts 6.2**
uiremes: Req
**Validatents base poixactly 1000clude eould in score shulated, the calcubmissionct answer sy* corre
*For anct answers for correscore0: Base y 2ropert
P
ropertiescoring P
### S 5.6**
ts Requiremendates:*Valichanged
*main unshould re answer e firstcted, and thd be rejehoul answer sng a seconditti, submionestt and quanipicany* party
*For n idempotencr submissio19: Answeroperty 

Pents 5.5**irems: RequValidates
**expireR the timer swered Oave an hpantsl partici alhen either question whe next to td advancesystem shoul the stion,For any* que
*tionscondigression ty 18: Pro
Proper4**
ents 5.Requirem: ateslidnt
**Vat participaor thawer fct ansn incorre aecordtem should rhe sys tero, zeachesmer rtihe er when td an answbmitteot suas n who hrticipant*For any* paswered
ks unanxpiry mar7: Timer erty 1

Propes 5.3**ementuirs: Req*Validatee
*otherwisse falect=s_corrnswer, and ict ahe correer matches t the answtrue ifrect=_cor isturnm should re

Propert
y 17: Timer expiry marks unanswered
*For any* participant who has not submitted an answer when the timer reaches zero, the system should record an incorrect answer for that participant
**Validates: Requirements 5.4**

Property 18: Progression conditions
*For any* question, the system should advance to the next question when either all participants have answered OR the timer expires
**Validates: Requirements 5.5**

Property 19: Answer submission idempotency
*For any* participant and question, submitting a second answer should be rejected, and the first answer should remain unchanged
**Validates: Requirements 5.6**

### Scoring Properties

Property 20: Base score for correct answers
*For any* correct answer submission, the calculated score should include exactly 1000 base points
**Validates: Requirements 6.2**

Property 21: Time bonus calculation
*For any* answer submission, faster response times should earn higher time bonuses, with a maximum of 500 points for immediate responses and 0 points at 30 seconds
**Validates: Requirements 6.3**

Property 22: Score update broadcast
*For any* participant whose score changes, that participant should receive a score update message
**Validates: Requirements 6.4**

Property 23: Leaderboard recalculation on score change
*For any* score change, the leaderboard rankings should be recalculated to reflect the new scores
**Validates: Requirements 6.5, 7.1**

### Leaderboard Properties

Property 24: Leaderboard data completeness
*For any* leaderboard entry, it should contain rank, username, and total score fields
**Validates: Requirements 7.2**

Property 25: Leaderboard broadcast on update
*For any* leaderboard update, all participants should receive the updated rankings
**Validates: Requirements 7.3**

Property 26: Leaderboard before next question
*For any* completed question, the leaderboard update message should be sent before the next question message
**Validates: Requirements 7.4**

### Answer Reveal Properties

Property 27: Answer reveal triggers
*For any* question, the correct answer should be revealed when either all participants have answered OR the timer expires
**Validates: Requirements 8.1**

Property 28: Reveal message contains correct answer
*For any* answer reveal message, it should contain the correct answer value
**Validates: Requirements 8.2**

Property 29: Answer distribution statistics
*For any* answer reveal message, it should include the count of participants who selected each option
**Validates: Requirements 8.3**

Property 30: Reveal timing delay
*For any* answer reveal, there should be a 5-second delay before advancing to the next question
**Validates: Requirements 8.4**

Property 31: Personal correctness feedback
*For any* answer reveal message sent to a participant, it should indicate whether that participant answered correctly
**Validates: Requirements 8.5**

### Quiz Completion Properties

Property 32: Final question completion transitions state
*For any* session where the last question is answered, the game state status should transition to "completed"
**Validates: Requirements 9.1**

Property 33: Completion calculates final rankings
*For any* completed quiz, final rankings should be calculated for all participants
**Validates: Requirements 9.2**

Property 34: Final results participant limit
*For any* final results display, it should show at most the top 10 participants
**Validates: Requirements 9.3**

Property 35: Accuracy calculation
*For any* participant in final results, their accuracy should equal (correct answers / total answered questions)
**Validates: Requirements 9.5**

Property 36: Results persistence
*For any* completed quiz, the session results should be persisted to the database
**Validates: Requirements 9.6**

### Reconnection Properties

Property 37: Reconnection state sync
*For any* participant who reconnects, they should receive the current question and game state
**Validates: Requirements 10.3**

Property 38: Long disconnection penalty
*For any* participant disconnected for more than 60 seconds, all remaining unanswered questions should be marked as incorrect
**Validates: Requirements 10.4**

### Host Control Properties

Property 39: Host authorization for termination
*For any* early termination request, it should be rejected if the requesting user is not the session host
**Validates: Requirements 11.1**

Property 40: Early termination transitions state
*For any* session, when the host ends the quiz early, the status should transition to "completed"
**Validates: Requirements 11.2**

Property 41: Early termination partial scoring
*For any* quiz ended early, final scores should be calculated based only on questions that were answered
**Validates: Requirements 11.3**

Property 42: Early termination broadcasts results
*For any* quiz ended early, final results should be broadcast to all participants
**Validates: Requirements 11.4**

Property 43: Connection cleanup after completion
*For any* completed quiz, all WebSocket connections should be closed after results are displayed
**Validates: Requirements 11.5**

### Security Properties

Property 44: Timestamp validation
*For any* answer submission, if the submission timestamp is after the question timer expiry, the submission should be rejected
**Validates: Requirements 12.1, 12.2**

Property 45: Host action authorization
*For any* host-only action (start, end), the request should be rejected if the requesting user is not the session host
**Validates: Requirements 12.4**

## Error Handling

### Connection Errors

**Scenario**: WebSocket connection fails or drops
**Handling**:
1. Client detects disconnection through connection close event or ping timeout
2. Client displays "Reconnecting..." overlay (non-blocking)
3. Client attempts reconnection with exponential backoff: 0s, 1s, 2s, 4s, 8s, 16s, 30s (max)
4. On successful reconnection, client sends reconnect message with user_id and session_code
5. Server validates session is still active and restores participant state
6. Server sends current game state to reconnected client
7. If reconnection fails after 60 seconds, client displays "Connection lost" error and exits to lobby

**Error Messages**:
- `CONNECTION_LOST`: "Connection lost. Reconnecting..."
- `RECONNECTION_FAILED`: "Unable to reconnect. Please check your internet connection."
- `SESSION_EXPIRED`: "This session has expired."

### Session Errors

**Scenario**: Invalid session code or expired session
**Handling**:
1. Server validates session code exists in Redis
2. Server checks session expiration timestamp
3. If invalid or expired, server returns error response
4. Client displays error message and returns to join screen

**Error Messages**:
- `SESSION_NOT_FOUND`: "Session not found. Please check the code and try again."
- `SESSION_EXPIRED`: "This session has expired."
- `SESSION_ALREADY_STARTED`: "This quiz has already started."
- `SESSION_FULL`: "This session is full."

### Answer Submission Errors

**Scenario**: Invalid answer or late submission
**Handling**:
1. Server validates submission timestamp against question timer
2. Server validates answer format matches question type
3. Server checks participant hasn't already answered
4. If validation fails, server returns error (but doesn't disconnect)
5. Client displays brief error toast

**Error Messages**:
- `ANSWER_TOO_LATE`: "Time's up! Your answer was not recorded."
- `ALREADY_ANSWERED`: "You have already answered this question."
- `INVALID_ANSWER`: "Invalid answer format."

### Authorization Errors

**Scenario**: Non-host attempts host action
**Handling**:
1. Server validates requesting user_id matches session host_id
2. If not authorized, server returns error
3. Client displays error message

**Error Messages**:
- `NOT_AUTHORIZED`: "Only the host can perform this action."
- `INVALID_HOST`: "Invalid host credentials."

## Testing Strategy

### Unit Testing

**Backend Unit Tests** (pytest):
- Session code generation uniqueness
- Score calculation logic (base + time bonus)
- Leaderboard ranking algorithm
- Session state transitions
- Answer validation logic
- Timer expiry handling
- Authorization checks

**Frontend Unit Tests** (flutter_test):
- WebSocket message parsing
- StateNotifier state transitions
- Timer countdown logic
- Score display formatting
- Leaderboard sorting
- Provider state updates

### Property-Based Testing

The system will use **Hypothesis** (Python) for backend property-based testing. Each property-based test will run a minimum of 100 iterations with randomly generated inputs.

**Property Test Configuration**:
- Each property-based test MUST be tagged with a comment explicitly referencing the correctness property
- Tag format: `# Feature: live-multiplayer-mode, Property X: [property description]`
- Each correctness property MUST be implemented by a SINGLE property-based test
- Tests MUST run at least 100 iterations

**Property Test Examples**:

1. **Session Code Uniqueness** (Property 1):
   - Generate N sessions
   - Verify all session codes are unique
   - Verify all codes are 6 characters alphanumeric

2. **Score Calculation** (Properties 20, 21):
   - Generate random correctness values and response times
   - Verify correct answers always include 1000 base points
   - Verify time bonus decreases linearly from 500 to 0 over 30 seconds
   - Verify incorrect answers always score 0

3. **Participant Count** (Property 4):
   - Generate random initial participant counts
   - Add a participant
   - Verify count increased by exactly 1

4. **State Transitions** (Properties 3, 12, 32, 40):
   - Generate sessions in various states
   - Apply state transition actions
   - Verify resulting state matches expected state

5. **Authorization** (Properties 39, 45):
   - Generate random user IDs (host and non-host)
   - Attempt host actions with both
   - Verify only host actions succeed

### Integration Testing

**WebSocket Integration Tests**:
- Full session lifecycle (create → join → start → play → complete)
- Multiple participants joining simultaneously
- Participant disconnect and reconnect
- Host ending quiz early
- Timer expiry with no answers
- All participants answering before timer expires

**Load Testing**:
- 100 concurrent sessions with 10 participants each
- Measure message latency (target: < 100ms p95)
- Measure CPU and memory usage
- Verify no message loss or duplication

### End-to-End Testing

**Automated E2E Tests** (Flutter integration tests):
- Host creates session and starts quiz
- Participant joins and answers questions
- Leaderboard updates correctly
- Final results display correctly
- Reconnection after network interruption

## Performance Considerations

### Latency Targets

- WebSocket message round-trip: < 100ms (p95)
- Question broadcast to all participants: < 200ms
- Leaderboard update calculation: < 50ms
- Answer submission processing: < 30ms

### Scalability

**Single Server Capacity**:
- Target: 1000 concurrent sessions
- 10,000 concurrent WebSocket connections
- Redis handles session state (in-memory, fast)
- MongoDB handles persistence (async, non-blocking)

**Horizontal Scaling** (Future):
- Redis Pub/Sub for cross-server message broadcasting
- Load balancer distributes WebSocket connections
- Sticky sessions ensure participants stay on same server
- Shared Redis cluster for session state

### Bandwidth Optimization

- Message compression (gzip) for large payloads
- Delta updates for leaderboard (only changed ranks)
- Batch participant updates (not individual messages)
- Question pre-loading (send next question during reveal phase)

## Security Considerations

### Authentication

- JWT tokens for WebSocket authentication
- Token included in WebSocket connection URL or initial message
- Server validates token before accepting connection
- Tokens expire after 24 hours

### Authorization

- Server validates host_id for all host actions
- Server validates user_id for all participant actions
- Server rejects actions from unauthorized users

### Input Validation

- Session codes: 6 alphanumeric characters only
- Usernames: 3-20 characters, alphanumeric + spaces
- Answer values: validated against question type
- Timestamps: validated against server time (±5 second tolerance)

### Anti-Cheat Measures

- All scoring calculations performed server-side
- Answer submissions validated against timer
- Duplicate answer submissions rejected
- Impossible response times (< 100ms) flagged
- Rate limiting on WebSocket messages (max 10/second per client)

### Data Privacy

- Session data deleted after 24 hours
- Personal data (usernames) not shared outside session
- No persistent user tracking across sessions
- HTTPS/WSS encryption for all communication

## Deployment Considerations

### Infrastructure

**Development**:
- Local FastAPI server with uvicorn
- Local Redis instance
- Local MongoDB instance
- Flutter app connects to localhost

**Production**:
- FastAPI deployed on cloud platform (AWS/GCP/Azure)
- Redis managed service (AWS ElastiCache, Redis Cloud)
- MongoDB Atlas for database
- WebSocket load balancer with sticky sessions
- CDN for static assets

### Monitoring

**Metrics to Track**:
- Active sessions count
- Connected participants count
- WebSocket connection errors
- Message latency (p50, p95, p99)
- Redis memory usage
- MongoDB query performance
- Server CPU and memory usage

**Alerts**:
- WebSocket connection error rate > 5%
- Message latency p95 > 200ms
- Redis memory usage > 80%
- Server CPU usage > 80%

### Configuration

**Environment Variables**:
```
REDIS_URL=redis://localhost:6379
MONGODB_URL=mongodb://localhost:27017
JWT_SECRET=<secret_key>
SESSION_EXPIRY_HOURS=24
QUESTION_TIMER_SECONDS=30
ANSWER_REVEAL_SECONDS=5
MAX_PARTICIPANTS_PER_SESSION=50
WEBSOCKET_PING_INTERVAL=30
RECONNECTION_TIMEOUT_SECONDS=60
```

## Future Enhancements

1. **Voice Chat**: Integrate WebRTC for voice communication during quiz
2. **Custom Timer**: Allow hosts to configure question time limits
3. **Power-ups**: Special abilities participants can use (freeze timer, 50/50, etc.)
4. **Team Mode**: Participants form teams and scores are aggregated
5. **Spectator Mode**: Allow users to watch sessions without participating
6. **Replay**: Save and replay quiz sessions
7. **Analytics**: Detailed statistics on question difficulty and participant performance
8. **Mobile Notifications**: Push notifications for session invites and results
