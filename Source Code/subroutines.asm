
Startup:
  LDA #$00
  STA ControllerHandler
  LDA #TITLESCREEN
  STA Gamestate
  RTS
  
  
InitialState:
  JSR LoadPlayer
  JSR AddEnemy
  JSR LoadPowerLevelSprite
  LDX #$01
  STA PowerBalance
  STA FiringRate
  STA AmmoMovingLoop
  STA AmmSprBaseAdr
  LDA #$01
  STA PowerBalance	; 1-4
  LDX #$00
  LDA PowerBalanceToFiringRate
  STA FiringRate
  LDA #$00
  STA ScoreOnes
  STA ScoreTens
  STA ScoreHundreds
  STA ScoreThousands
  STA HighScoreOnes
  STA HighScoreTens
  STA HighScoreHundreds
  STA HighScoreThousands
  RTS
  
  
ReadController1:
  LDA #$01
  STA $4016
  LDA #$00
  STA $4016
  LDX #$08
ReadController1Loop:
  LDA $4016
  LSR A
  ROL PlayerOneController
  DEX
  BNE ReadController1Loop
  RTS

BPressed:
  LDA GunTimer
  CMP FiringRate
  BMI CantShoot
  JSR Shoot
  LDA #$00
  STA GunTimer
CantShoot:
  RTS

UpPressed:
  LDA $0200	;load sprite Y position
  SEC	; make sure carry flag is set
  SBC #$01	; A = A - 1
  STA $0200	; save sprite Y position
  LDA $0204	;load sprite Y position
  SEC	;make sure carry flag is set
  SBC #$01	; A = A - 1
  STA $0204	;save sprite Y position
  LDA $0208	;load sprite Y position
  SEC	;make sure carry flag is set
  SBC #$01	; A = A - 1
  STA $0208	;save sprite Y position
  LDA $020C	;load sprite Y position
  SEC	;make sure carry flag is set
  SBC #$01	;A = A - 1
  STA $020C	;save sprite Y position
  RTS

DownPressed:
  LDA $0200	;load sprite Y position
  CLC	;make sure carry flag is clear
  ADC #$01	; A = A + 1
  STA $0200	;save sprite Y position
  LDA $0204	;load sprite Y position
  CLC	;make sure carry flag is clear
  ADC #$01	; A = A + 1
  STA $0204	;save sprite Y position
  LDA $0208	;load sprite Y position
  CLC	;make sure carry flag is clear
  ADC #$01	; A = A +1
  STA $0208	;save sprite Y position
  LDA $020C	;load sprite Y position
  CLC	;make sure carry flag is clear
  ADC #$01	; A = A + 1
  STA $020C	;save sprite Y position
  RTS

RightPressed:
  LDA $0203
  CLC	;make sure carry flag is set
  ADC #$01	; A = A - 1
  STA $0203
  LDA $0207
  CLC
  ADC #$01
  STA $0207
  LDA $020B
  CLC
  ADC #$01
  STA $020B
  LDA $020F
  CLC
  ADC #$01
  STA $020F
  RTS

LeftPressed:
  LDA $0203	;load sprite X position
  SEC	; 
  SBC #$01	;A = A + 1
  STA $0203	;save sprite X position
  LDA $0207	;load sprite X position
  SEC	;make sure carry flag is clear
  SBC #$01	;A = A + 1
  STA $0207	;save sprite X position
  LDA $020B	;load sprite X position
  SEC	;make sure carry flag is clear
  SBC #$01	; A = A + 1
  STA $020B	;save sprite X position
  LDA $020F	;load sprite X position
  SEC	;make sure carry flag is set
  SBC #$01
  STA $020F	;save sprite X position
  RTS

Shoot:
  LDX #$00
AmmoSpaceSearchLoop:
  LDA AmmoSpaces, x
  CMP #$00	;checking if free
  BEQ AmmoSpaceFound
  INX
  CPX #$16
  BNE AmmoSpaceSearchLoop
  LDX #$00
AmmoSpaceFound:
  STX Temp
  LDA #$01
  STA AmmoSpaces, x
  LDA #$01
  JSR SFX
  LDA Temp
  ASL A
  ASL A
  TAX
  LDA $0204	;player sprite bottom right y pos
  STA AmmoSprite, x
  INX
  LDA #$30	;tile num
  STA AmmoSprite, x
  INX
  LDA #%00000010
  STA AmmoSprite, x	;attr
  INX
  LDA $0207	;x pos
  CLC
  ADC #$02
  STA AmmoSprite, x
ShootingDone:
  RTS
  
;
;
; when i figure out code for missing engine, place here, above drawing scores
;
  
DrawGameBackground:
LoadGameBackground:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$81
  STA $2006
  LDA #LOW(gameBackground)
  STA PointerLow
  LDA #HIGH(gameBackground)
  STA PointerHigh
  LDY #$00
  LDX #$00
OutsideGameBackgroundLoop:
InsideGameBackgroundLoop:
  LDA [PointerLow], Y
  STA $2007
  INY
  CPY #$00
  BNE InsideGameBackgroundLoop
  INC PointerHigh
  INX
  CPX #$04
  BNE OutsideGameBackgroundLoop
DrawGameBackground2:
LoadGameBackground2:
  LDA $2002
  LDA #$24
  STA $2006
  LDA #$80
  STA $2006
  LDA #LOW(gameBackground)
  STA PointerLow
  LDA #HIGH(gameBackground)
  STA PointerHigh
  LDY #$00
  LDX #$00
OutsideGameBackgroundLoop2:
InsideGameBackgroundLoop2:
  LDA [PointerLow], Y
  STA $2007
  INY
  CPY #$00
  BNE InsideGameBackgroundLoop2
  INC PointerHigh
  INX
  CPX #$04
  BNE OutsideGameBackgroundLoop2
  RTS
  
DrawTitleScreen:
LoadTitleBackground:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006
  LDA #LOW(titleBackground)
  STA PointerLow
  LDA #HIGH(titleBackground)
  STA PointerHigh
  LDX #$00
  LDY #$00
OutsideTitleBackgroundLoop:
InsideTitleBackgroundLoop:
  LDA [PointerLow], y
  STA $2007
  INY
  CPY #$00
  BNE InsideTitleBackgroundLoop	;loop 255 times
  INC PointerHigh
  INX
  CPX #$04
  BNE OutsideTitleBackgroundLoop
  RTS
  
DrawCreditsScreen:
LoadCreditsBackground:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006
  LDA #LOW(creditsBackground)
  STA PointerLow
  LDA #HIGH(creditsBackground)
  LDX #$00
  LDY #$00
OutsideCreditsBackgroundLoop:
InsideCreditsBackgroundLoop:
  LDA [PointerLow], Y
  STA $2007
  INY
  CPY #$00
  BNE InsideCreditsBackgroundLoop
  INC PointerHigh
  INX
  CPX #$04
  BNE OutsideCreditsBackgroundLoop
  RTS
  
IncScore:
IncOnes:
  LDA ScoreOnes
  CLC
  ADC #$01 	;add one
  STA ScoreOnes
  CMP #$0A	;check if overflowed
  BNE IncScoreDone	; if none, all done 
IncTens:
  LDA #$00
  STA ScoreOnes	;wrap digit to 0
  LDA ScoreTens	;load next digit
  CLC
  ADC #$01	; add one, carry from previous dig.
  STA ScoreTens
  CMP #$0A	;check for overflow, now 10
  BNE IncScoreDone
IncHundreds:
  LDA #$00
  STA ScoreTens
  LDA ScoreHundreds
  CLC
  ADC #$01
  STA ScoreHundreds
  CMP #$0A
  BNE IncScoreDone
IncThousands:
  LDA #$00
  STA ScoreHundreds
  LDA ScoreThousands
  CMP #$09	;check to see if player hits max (9999)
  BEQ KeepScoreMax
  INC ScoreHundreds
  JMP IncScoreDone
KeepScoreMax:
  LDA #$09
  STA ScoreOnes
  STA ScoreTens
  STA ScoreHundreds
  STA ScoreThousands 
IncScoreDone:
  RTS
  
UpdateHighScore:
UpdateHighScoreThousandsCheck:
  LDA ScoreThousands
  CMP HighScoreThousands
  BMI NoNewHighScore
  LDA ScoreThousands
  CMP HighScoreThousands
  BEQ UpdateHighScoreHundredsCheck
  JMP NewHighScore
UpdateHighScoreHundredsCheck:
  LDA ScoreHundreds
  CMP HighScoreHundreds
  BMI NoNewHighScore
  LDA ScoreHundreds
  CMP HighScoreHundreds
  BEQ UpdateHighScoreTensCheck
  JMP NewHighScore
UpdateHighScoreTensCheck:
  LDA ScoreTens
  CMP HighScoreTens
  BMI NoNewHighScore
  LDA ScoreTens
  CMP HighScoreTens
  BEQ UpdateHighScoreOnesCheck
  JMP NewHighScore
UpdateHighScoreOnesCheck:
  LDA ScoreOnes
  CMP HighScoreOnes
  BMI NoNewHighScore
NewHighScore:
  LDA ScoreOnes
  STA HighScoreOnes
  LDA ScoreTens
  STA HighScoreTens
  LDA ScoreHundreds
  STA HighScoreHundreds
  LDA ScoreThousands
  STA HighScoreThousands
NoNewHighScore:
  RTS
  
DrawScore:
  LDA $2002
  LDA #$20	; High byte of where to load in name table
  STA $2006
  LDA #$61 	  ; Low byte of where to load in name table
  STA $2006
  LDA ScoreThousands
  STA $2007
  LDA ScoreHundreds
  STA $2007
  LDA ScoreTens
  STA $2007
  LDA ScoreOnes
  STA $2007
DrawScore2:
  LDA $2002
  LDA #$24	; High byte of where to load in name table
  STA $2006
  LDA #$61 	  ; Low byte of where to load in name table
  STA $2006
  LDA ScoreThousands
  STA $2007
  LDA ScoreHundreds
  STA $2007
  LDA ScoreTens
  STA $2007
  LDA ScoreOnes
  STA $2007
  RTS
  
DrawHighScore:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$8D
  STA $2006
  LDA HighScoreThousands
  STA $2007
  LDA HighScoreHundreds
  STA $2007
  LDA HighScoreTens
  STA $2007
  LDA HighScoreOnes
  STA $2007
DrawHighScore2:
  LDA $2002
  LDA #$24
  STA $2006
  LDA #$8D
  STA $2006
  LDA HighScoreThousands
  STA $2007
  LDA HighScoreHundreds
  STA $2007
  LDA HighScoreTens
  STA $2007
  LDA HighScoreOnes
  STA $2007
  RTS

RunStartGame:
  JSR StartGame
  RTS
  
RunCreditsScreen:
  JSR CreditsScreen
  RTS
  
CreditsScreen:
  LDA #$00
  STA $2000
  STA $2001
  LDA #CREDITSSCREEN
  STA Gamestate
  JSR DrawCreditsScreen
  LDA #%10010000
  STA $2000
  LDA #%00011110
  STA $2001
  JSR SelectorOff
  RTS
 
StartGame:
  LDA #$00	;Turn off screen before redrawing
  STA $2000
  STA $2001
  LDA #GAMESCREEN
  STA Gamestate
  JSR InitialState
  JSR DrawGameBackground
  JSR DrawStatusBar
  JSR DrawStatusBar2
  LDA #%10010000
  STA $2000
  LDA #%00011110
  STA $2001
  JSR SelectorOff ; no selection arrow
  RTS
  
TitleSelect:
  LDA TitleSelectSpot
  CMP #START
  BNE MoveToStart
MoveToSelect:
  LDA #CREDITS
  STA TitleSelectSpot
  JSR TitleScreenSelectorCredits
  JMP DoneWithTitleSelect  
MoveToStart:
  LDA #START
  STA TitleSelectSpot
  JSR TitleScreenSelectorStart

  
DoneWithTitleSelect:
  LDA #$01
  STA ControllerHandler
  RTS
  
HandleTitleStart:
  LDA TitleSelectSpot
  CMP #START
  BEQ RunStartGame
  CMP #CREDITS
  BEQ RunCreditsScreen
  RTS

TitleScreenSelectorStart:
  LDA #$B0	;y coord
  STA $0290
  LDA #$25	;nametable
  STA $0291
  LDA $00	;attr
  STA $0292
  LDA #$4F	;x coord
  STA $0293
  RTS 
  
TitleScreenSelectorCredits:
  LDA #$C0
  STA $0290
  LDA #$25
  STA $0291
  LDA $00
  STA $0292
  LDA #$4F
  STA $0293
  RTS
    
SelectorOff:
  LDA #$F0
  STA $0290
  LDA $25
  STA $0291
  LDA #$00
  STA $0292
  STA $0293
  RTS
  
ReturnToTitle:
  LDA #$00
  STA $2000
  STA $2001
  JSR DrawTitleScreen
  LDA #%10010000
  STA $2000
  LDA #%00011110
  STA $2001
  JSR TitleScreenSelectorStart
  JSR Startup
  RTS
  
RemoveEnemy:
  CPY #$00
  BEQ RemoveEnemy1
  CPY #$01
  BEQ RemoveEnemy2
  CPY #$02
  BEQ RemoveEnemy3
  CPY #$03
  BEQ RemoveEnemy4
  CPY #$04
  BEQ RemoveEnemy5
  CPY #$05
  BEQ RemoveEnemy6
  RTS
RemoveEnemy1:
  LDA #$00
  STA $0231
  STA $0235
  STA $0239
  STA $023D
  STA EnemyDmg, y
  STA EnemyInAir, y
  RTS
RemoveEnemy2:
  LDA #$00
  STA $0241
  STA $0245
  STA $0249
  STA $024D
  STA EnemyDmg, y
  STA EnemyInAir, y
  RTS
RemoveEnemy3:
  LDA #$00
  STA $0251
  STA $0255
  STA $0259
  STA $025D
  STA EnemyDmg, y
  STA EnemyInAir, y
  RTS
RemoveEnemy4:
  LDA #$00
  STA $0261
  STA $0265
  STA $0269
  STA $026D
  STA EnemyDmg, y
  STA EnemyInAir, y
  RTS
RemoveEnemy5:
  LDA #$00
  STA $0271
  STA $0275
  STA $0279
  STA $027D
  STA EnemyDmg, y
  STA EnemyInAir, y
  RTS
RemoveEnemy6:
  LDA #$00
  STA $0281
  STA $0285
  STA $0289
  STA $028D
  STA EnemyDmg, y
  STA EnemyInAir, y
  RTS
  
  

LoadPlayer:
  LDX #$00	;start at 00
LoadSpritesLoop:
  LDA Sprite_Player, x	;load data from address
  STA $0200, x	;store into RAM
  INX	; x = x+1
  CPX #$10	;compare X to hex $10, decimal 16
  BNE LoadSpritesLoop
  RTS
  
LoadGameOverSprite:
  LDX #$00
LoadGameOverSpriteLoop:
  LDA Sprite_Gameover, x
  STA $0210, x
  INX
  CPX #$20	;decimal 32
  BNE LoadGameOverSpriteLoop
  RTS
  
LoadEnemy1:
  LDX #$00
LoadEnemy1Loop:
  LDA Sprite_Enemy1, x
  STA $0230, x
  INX
  CPX #$10
  BNE LoadEnemy1Loop
  LDA #$01
  STA EnemyInAir
  RTS

LoadEnemy2:
  LDX #$00
LoadEnemy2Loop:
  LDA Sprite_Enemy2, x
  STA $0240, x
  INX
  CPX #$10
  BNE LoadEnemy2Loop
  LDX #$01
  LDA #$01
  STA EnemyInAir, x
  RTS

LoadEnemy3:
  LDX #$00
LoadEnemy3Loop:
  LDA Sprite_Enemy3, x
  STA $0250, x
  INX
  CPX #$10
  BNE LoadEnemy3Loop
  LDX #$02
  LDA #$01
  STA EnemyInAir, x
  RTS

LoadEnemy4:
  LDX #$00
LoadEnemy4Loop:
  LDA Sprite_Enemy4, x
  STA $0260, x
  INX
  CPX #$10
  BNE LoadEnemy4Loop
  LDX #$03
  LDA #$01
  STA EnemyInAir, x
  RTS

LoadEnemy5:
  LDX #$00
LoadEnemy5Loop:
  LDA Sprite_Enemy5, x
  STA $0270, x
  INX
  CPX #$10
  BNE LoadEnemy5Loop
  LDX #$04
  LDA #$01
  STA EnemyInAir, x
  RTS

LoadEnemy6:
  LDX #$00
LoadEnemy6Loop:
  LDA Sprite_Enemy6, x
  STA $0280, x
  INX
  CPX #$10
  BNE LoadEnemy6Loop
  LDX #$05
  LDA #$01
  STA EnemyInAir, x
  RTS
  
LoadPowerLevelSprite:
  LDX #$00
LoadPowerLevelSpriteLoop:
  LDA PowerLevelSprite, x
  STA $02F4, x
  INX
  CPX #$04
  BNE LoadPowerLevelSpriteLoop
  
AddEnemy:
  JSR LoadEnemy1
  JSR LoadEnemy2
  JSR LoadEnemy3
  JSR LoadEnemy4
  JSR LoadEnemy5
  JSR LoadEnemy6
  RTS
    
GameOver:
  LDA #$10	;turn off nmi
  STA $2000
  LDA #$1E
  STA $2001
  JSR LoadGameOverSprite
  JSR LoadMoreGameOverSprite
  JSR LoadMoreGameOverSprite2
  JSR StoreSprite
GameOverLoop:
  JSR ReadController1
  LDA PlayerOneController
  AND #%00010000	;start
  BEQ NoStartPress
  JSR Delay
  JMP GameReturnToTitle
NoStartPress:
  JMP GameOverLoop
  
GameReturnToTitle:
  LDA #$00 
  STA $2000
  STA $2001
  JSR ClearSprMem
  JSR RefillPalette
  JSR Clear2ndNameTable
  JSR DrawTitleScreen
  LDA #%10010000	;turn nmi back on
  STA $2000
  LDA #%00011110
  STA $2001
  JSR TitleScreenSelectorStart
  JSR Startup
  LDA #$00
  STA Scroll
  JMP NMI
  RTS
  
  
StoreSprite:
  LDA #$00
  STA $2003
  LDA #$02
  STA $4014
  RTS
  
RefillPalette:
  LDA #$3F
  STA $2006
  LDA #$00
  STA $2006
  RTS
  
ClearSprMem:
  LDX #$00
  LDA #$00
ClearSprMemLoop:
  STA $0200, x
  INX
  CPX #$00
  BNE ClearSprMemLoop
  RTS

  
LoadMoreGameOverSprite:
  LDX #$00
LoadMoreGameOverSpriteLoop:
  LDA More_GameOver_Sprite, x
  STA $0294, x
  INX
  CPX #$10
  BNE LoadMoreGameOverSpriteLoop
  RTS
  
LoadMoreGameOverSprite2:
  LDX #$00
LoadMoreGameOverSprite2Loop:
  LDA More_GameOver_Sprite2, x
  STA $02A4, x
  INX
  CPX #$10
  BNE LoadMoreGameOverSprite2Loop
  RTS
  
DrawStatusBar:
LoadStatusBar:
  LDA $2002
  LDA #$20
  STA $2006
  LDA #$00
  STA $2006
  LDY #$00
  LDX #$00
OutsideStatusBarLoop:
InsideStatusBarLoop:
  LDA statusbar, y
  STA $2007
  INY
  CPY #$80
  BNE InsideStatusBarLoop
  RTS
  
  
DrawStatusBar2:
LoadStatusBar2:
  LDA $2002
  LDA #$24
  STA $2006
  LDA #$00
  STA $2006
  LDY #$00
  LDX #$00
OutsideStatusBar2Loop:
InsideStatusBar2Loop:
  LDA statusbar, y
  STA $2007
  INY
  CPY #$80
  BNE InsideStatusBar2Loop
  RTS
  
Clear2ndNameTable: 
  LDA $2002
  LDA #$24
  STA $2006
  LDA #$00
  STA $2006
  LDY #$00
Clear2ndNameTableLoop:
  LDA #$00
  STA $2007
  INY
  CPY #$00
  BNE Clear2ndNameTableLoop
  INX
  CPX #$04
  BNE Clear2ndNameTableLoop
  RTS

Delay:
  LDA #$03
  STA Temp
DelayTemp:
  LDX #$80
DelayX:
  LDY #$FF
DelayY:
  DEY
  BNE DelayY
  DEX
  BNE DelayX
  DEC Temp
  BNE DelayTemp
  RTS
 
UpdatePowerLevelSprite:
  LDA PowerBalance
  CLC
  ADC #$1A
  STA $02F5
  LDA #$04
  JSR SFX
  RTS
  
SFX:
  CMP #$01	;marks number/type of sound - in this case, ammo being shot
  BNE SFX2
  LDA #%00111110	;duty cycle = 00 (weak,grainy) volume = E
  STA $4000
  LDA #%10000011	;sweep
  STA $4001
  LDA #$FB	;low byte, A note Octave 4
  STA $4002
  LDA #$01	;high byte, 01+fb= 01fb
  STA $4003
  RTS
SFX2:
  CMP #$02	;ammo hitting an enemy
  BNE SFX3
  LDA #%00111110	;duty cycle = 00, volume = E
  STA $4004
  LDA #%10000011	;sweep
  STA $4005
  LDA #$D2	;low byte, C note Octave 4
  STA $4006
  LDA #$00	;high byte
  STA $4007
  RTS
SFX3:
  CMP #$03	;enemy died
  BNE SFX4
  LDA #%00111110	;duty cycle = 0, volume = E
  STA $4004
  LDA #%11001011	;sweep
  STA $4005
  LDA #$B3
  STA $4006
  LDA #$00
  STA $4007  
  RTS
SFX4:
  CMP #$04	;bonus
  BNE SFX5
  LDA #%00111111	;duty cycle = 0, volume = F
  STA $4004
  LDA #%11001010	;sweep
  STA $4005
  LDA #$FD	;low byte, octave 4 note A
  STA $4006
  LDA #$00	;high byte
  STA $4007
  RTS
SFX5:
  CMP #$05	;game over
  BNE NoSFX
  LDA #%10111111	;duty cycle = 2 (loud,strong tone) volume = F
  STA $4004
  LDA #%10110011	;sweep
  STA $4005
  LDA #$F9	;low byte, octave 2 note D
  STA $4006
  LDA #$02	;high byte
  STA $4007
  RTS
NoSFX:
  RTS
  

  
