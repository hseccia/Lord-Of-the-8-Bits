  .inesprg 1	; 1x 16KB PRG code
  .ineschr 1	; 1X 8KB CHR data
  .inesmap 0	; mapper 0 = NROM, no bank swapping
  .inesmir 0	; background mirroring
  
  ;;; Coded By Derpboss64 (Hannah Seccia) ;;;
  ;;; Approximate Date: May 2015 ;;;
  
  .rsset $0000
RandomNumber		.rs 1
Counter				.rs 1
PlayerOneController	.rs 1
ControllerHandler	.rs 1
Gamestate			.rs 1
ScoreOnes			.rs 1
ScoreTens			.rs 1
ScoreHundreds		.rs 1
ScoreThousands		.rs 1
TitleSelectSpot		.rs 1
PointerLow			.rs 1
PointerHigh			.rs 1
HighScoreOnes		.rs 1
HighScoreTens		.rs 1
HighScoreHundreds	.rs 1
HighScoreThousands	.rs 1
Scroll				.rs 1
Nametable			.rs 1
EnemyInAir			.rs 6
Enemy1Coord			.rs 3
Enemy2Coord			.rs 3
Enemy3Coord			.rs 3
Enemy4Coord			.rs 3
Enemy5Coord			.rs 3
Enemy6Coord			.rs 3
Temp				.rs 1
PowerBalance		.rs 1
FiringRate			.rs 1
AmmoMovingLoop		.rs 1
AmmSprBaseAdr		.rs 1
AmmoSpaces			.rs 20
GunTimer			.rs 1
EnemyLefts			.rs 6
EnemyYPos1			.rs 6
EnemyYPos2			.rs 6
EnemyDmg			.rs 6
EnemiesDestroyed	.rs 1
EnemyRights			.rs 6





TITLESCREEN = $00
GAMESCREEN = $01
CREDITSSCREEN = $02
START = $00
CREDITS = $01

  
;;; STARTUP CODE ;;;
  
  .bank 0
  .org $C000 

RESET:
  SEI	; disable IRQs
  CLD	; disable decimal mode
  LDX #$40
  STX $4017	;disable APU frame IRQ
  LDX #$FF
  TXS	;set up stack
  INX	;now X = 0
  STX $2000	;disable NMI
  STX $2001	;disable rendering
  STX $4010	;disable DMC IRQs
  LDA #%00000011
  STA $4015	;enable sounds
  
vblankwait1:	;wait for vblank
  BIT $2002
  BPL vblankwait1

clrmem:
  LDA #$00
  STA $0000, x
  STA $0100, x
  STA $0300, x
  STA $0400, x
  STA $0500, x
  STA $0600, x
  STA $0700, x
  LDA #$FE
  STA $0200, x
  INX
  BNE clrmem
  
vblankwait2:
  BIT $2002
  BPL vblankwait2	;jump to vblank wait again, returns here
    
LoadPalettes:
  LDA $2002	; read PPU status
  LDA #$3F
  STA $2006	;write the high byte of $3F00 address
  LDA #$00
  STA $2006	;write the low byte of $3F00 address
  LDX #$00	;start out at 0
LoadPalettesLoop:
  LDA palette, x	;load data from address (PaletteData + the value in x)
  STA $2007	;write to PPU
  INX
  CPX #$20 	;compare X to hex $20
  BNE LoadPalettesLoop	;branch to LoadPalettesLoop if compare was not equal to zero
  
  JSR DrawTitleScreen
  JSR TitleScreenSelectorStart
  
FillAttribute:
  LDA $2002	;read PPU status to reset the high/low latch
  LDA #$23
  STA $2006	;write the high byte of $23C0 adderess
  LDA #$C0
  STA $2006	;write the low byte
  LDX #$40 	;fill 64 bytes
  LDA #$00
FillAttributeLoop:
  STA $2007	;write to PPU
  DEX
  BNE FillAttributeLoop
  
FillAttribute1:
  LDA $2002
  LDA #$27
  STA $2006
  LDA #$C0
  STA $2006
  LDX #$40
  LDA #$00
FillAttribute1Loop:
  STA $2007
  DEX
  BNE FillAttribute1Loop
  
StartUpState:
  JSR Startup 
  
  ;;;;
 
  LDA #%10010000	;enable NMI, sprites from Pattern Table 0, background from Pattern Table 1
  STA $2000
  
  LDA #%00011110	;enable sprites, enable background, no clipping on left side
  STA $2001
  
 
Forever:
  JMP Forever ; jump back to Forever, infinite loop, waiting for NMI
  
GoToEnd:
  JMP EndGame
  
GoToEnd2:
  JMP EndGame
  
GoToEnd3:
  JMP EndGame
  
;;; NMI ;;;
  
NMI:
  LDA #$00	; set the low byte (00) of the RAM address
  STA $2003
  LDA #$02	; set the high byte (02) of the RAM address, start the transfer
  STA $4014
  
  LDA Gamestate	
  CMP #GAMESCREEN
  BEQ DrawGameScreen 
  JMP PPUCleanup	
  
DrawGameScreen:
  JSR DrawScore	
  JSR DrawHighScore
  	
  
PPUCleanup:
  LDA #$00
  STA $2006
  STA $2006	;clean up ppu address registers
  
  LDA Scroll
  STA $2005	;write the horizontal scroll count register
  
  LDA #$00
  STA $2005	;no vertical scrolling
  
  LDA #%10010000	;enable NMI, sprites from Pattern Table 0, background from Pattern Talbe 1
  ORA Nametable	;select correct nametable for bit 0
  STA $2000
  LDA #%00011110	;enable sprites, enable background, no clipping on left side
  STA $2001
	
;;; TITLE/CREDITS STUFF ;;;
	
StartPlay:

  LDA Gamestate
  CMP #TITLESCREEN
  BEQ PlayTitle
  CMP #GAMESCREEN
  BEQ PlayGame
  CMP #CREDITSSCREEN
  BEQ CreditsScreenState		
  JMP EndGame
  
CreditsScreenState:
  JSR ReadController1
  LDA PlayerOneController
  ORA #%00000000
  BEQ ControllerNotPressed
  LDA ControllerHandler
  CMP #$01
  BEQ GoToEnd
CheckSelectPressedCredits:
  LDA PlayerOneController
  AND #%00100000
  BEQ GoToEnd
  JSR ReturnToTitle
  
PlayTitle:
  JSR ReadController1	
  LDA PlayerOneController
  ORA #%00000000
  BEQ ControllerNotPressed
  LDA ControllerHandler
  CMP #$01
  BEQ GoToEnd3
CheckStartPressed:
  LDA PlayerOneController
  AND #%00010000	;Start
  BEQ CheckSelectPressed
  JSR HandleTitleStart	
CheckSelectPressed:
  LDA PlayerOneController
  AND #%00100000
  BEQ GoToEnd4
  JSR TitleSelect
  
    .include "gotoend.asm"
  
ControllerNotPressed:
  LDA #$00 ; Not pressed
  STA ControllerHandler
  JMP EndGame 	; no action, go to end
  
;;; START GAME ;;;
  
PlayGame:

;;; SCROLL ;;;

NTSwapDoCheck:
  INC Scroll
NTSwapCheck:
  LDA Scroll
  BNE NTSwapCheckDone
NTSwap:
  LDA Nametable
  EOR #$01
  STA Nametable
NTSwapCheckDone:


;;; ENEMY CODE ;;;

EnemyCoords:
  LDX #$00
  LDA $0238
  CLC
  SBC #$05
  STA Enemy1Coord, x
  INX
  LDA $023B
  CLC
  SBC #$05
  STA Enemy1Coord, x
  INX 
  LDA $0230
  CLC
  ADC #$05
  STA Enemy1Coord, x
  LDX #$00
  LDA $0248
  CLC
  SBC #$05
  STA Enemy2Coord, x
  INX
  LDA $024B
  CLC
  SBC #$05
  STA Enemy2Coord, x
  INX 
  LDA $0240
  CLC
  ADC #$05
  STA Enemy2Coord, x
  LDX #$00
  LDA $0258
  CLC
  SBC #$05
  STA Enemy3Coord, x
  INX
  LDA $025B
  CLC
  SBC #$05
  STA Enemy3Coord, x
  INX
  LDA $0250
  CLC
  ADC #$05
  STA Enemy3Coord, x
  LDX #$00
  LDA $0268
  CLC
  SBC #$05
  STA Enemy4Coord, x
  INX
  LDA $026B
  CLC
  SBC #$05
  STA Enemy4Coord, x
  INX
  LDA $0260
  CLC
  ADC #$05
  STA Enemy4Coord, x
  LDX #$00
  LDA $0278
  CLC
  SBC #$05
  STA Enemy5Coord, x
  INX
  LDA $027B
  CLC
  SBC #$05
  STA Enemy5Coord, x
  INX
  LDA $0270
  CLC
  ADC #$05
  STA Enemy5Coord, x
  LDX #$00
  LDA $0288
  CLC
  SBC #$05
  STA Enemy6Coord, x
  INX
  LDA $028B
  CLC
  SBC #$05
  STA Enemy6Coord, x
  INX
  LDA $0280
  CLC
  ADC #$05
  STA Enemy6Coord, x
EnemyCoordsDone:

  LDY #$00
EnemyYPosStore:
  LDA $0238
  CLC
  SBC #$06
  STA EnemyYPos1, y
  INY
  LDA $0248
  CLC
  SBC #$06
  STA EnemyYPos1, y
  INY
  LDA $0258
  CLC
  SBC #$06
  STA EnemyYPos1, y
  INY
  LDA $0268
  CLC
  SBC #$06
  STA EnemyYPos1, y
  INY
  LDA $0278
  CLC
  SBC #$06
  STA EnemyYPos1, y
  INY
  LDA $0288
  CLC
  SBC #$06
  STA EnemyYPos1, y
  LDY #$00
  LDA $0230
  CLC
  ADC #$06
  STA EnemyYPos2, y
  INY
  LDA $0240
  CLC
  ADC #$06
  STA EnemyYPos2, y
  INY
  LDA $0250
  CLC
  ADC #$06
  STA EnemyYPos2, y
  INY
  LDA $0260
  CLC
  ADC #$06
  STA EnemyYPos2, y
  INY
  LDA $0270
  CLC
  ADC #$06
  STA EnemyYPos2, y
  INY
  LDA $0280
  CLC
  ADC #$06
  STA EnemyYPos2, y
  LDY #$00
  LDA $0233
  CLC
  SBC #$06
  STA EnemyLefts, y
  INY
  LDA $0243
  CLC
  SBC #$06
  STA EnemyLefts, y
  INY
  LDA $0253
  CLC
  SBC #$06
  STA EnemyLefts, y
  INY
  LDA $0263
  CLC
  SBC #$06
  STA EnemyLefts, y
  INY
  LDA $0273
  CLC
  SBC #$06
  STA EnemyLefts, y
  INY
  LDA $0283
  CLC
  SBC #$06
  STA EnemyLefts, y
EnemyYPosDone:

EnemyRightCoords:
  LDX #$00
  LDA $0237
  CLC
  SBC #$05
  STA EnemyRights, x
  INX
  LDA $0247
  CLC
  SBC #$05
  STA EnemyRights, x
  INX
  LDA $0257
  CLC
  SBC #$05
  STA EnemyRights, x
  INX
  LDA $0267
  CLC
  SBC #$05
  STA EnemyRights, x
  INX
  LDA $0277
  CLC
  SBC #$05
  STA EnemyRights, x
  INX
  LDA $0287
  CLC
  SBC #$05
  STA EnemyRights, x
EnemyRightCoordsDone:

ControllerRead:
  JSR ReadController1
  LDA PlayerOneController	;;see if the controller was both pressed and pressed last frame
  ORA #%00000000	;see if up/down was pressed 
  BEQ MoveEnemy	;bits are 1, so controller is pressed
  LDA ControllerHandler
  CMP #$01	;controller already down
  BEQ MoveEnemy
  JMP CheckBPressed

  
  .include "controllernotpressed.asm"

CheckBPressed:
  LDA PlayerOneController
  AND #%01000000
  BEQ CantB
  JSR BPressed	
CantB:
CheckUpPressed:
  LDA PlayerOneController
  AND #%00001000
  BEQ CantUp
  JSR UpPressed	
CantUp:
CheckDownPressed:
  LDA PlayerOneController
  AND #%00000100
  BEQ CantDown
  JSR DownPressed
CantDown:
CheckLeftPressed:
  LDA PlayerOneController
  AND #%00000010
  BEQ CantLeft
  JSR LeftPressed
CantLeft:
CheckRightPressed:
  LDA PlayerOneController
  AND #%00000001
  BEQ PlayerControllerDone
  JSR RightPressed
PlayerControllerDone:
  JMP MoveEnemy

MoveEnemy:
  DEC $0233	;enemy 1
  DEC $0237
  DEC $023B	
  DEC $023F	
  DEC $0243	;enemy 2
  DEC $0247
  DEC $024B
  DEC $024F
  DEC $0253	;enemy 3
  DEC $0257
  DEC $025B
  DEC $025F
  DEC $0263	;enemy 4
  DEC $0267
  DEC $026B
  DEC $026F
  DEC $0273	;enemy 5
  DEC $0277
  DEC $027B
  DEC $027F
  DEC $0283	;enemy 6
  DEC $0287
  DEC $028B
  DEC $028F
MoveEnemyDone:

CheckIfInAir:
  LDX #$00	;enemy 1
  LDA #$00
  CMP EnemyInAir, x
  BNE NoResetEnemy
  INX	;enemy 2
  LDA #$00
  CMP EnemyInAir, x
  BNE NoResetEnemy
  INX	;enemy 3
  LDA #$00
  CMP EnemyInAir, x
  BNE NoResetEnemy
  INX	;enemy 4
  LDA #$00
  CMP EnemyInAir, x
  BNE NoResetEnemy
  INX	;enemy 5
  LDA #$00
  CMP EnemyInAir, x
  BNE NoResetEnemy
  INX	;enemy 6
  LDA #$00
  CMP EnemyInAir, x
  BNE NoResetEnemy
  JSR AddEnemy
NoResetEnemy:

  LDY #$00
EnemyCollisionLoop:
  LDA EnemyInAir, y
  CMP #$01
  BEQ CheckForEnemyCollision
  JMP NoCollision
CheckForEnemyCollision:
  LDA $0200	;bottom left y pos
  CMP EnemyYPos1, y
  BCC NoCollision
  LDA $020C	;top right y pos
  CMP EnemyYPos2, y
  BCS NoCollision	
  LDA $020B
  CMP EnemyLefts, y
  BCC NoCollision
  LDA $020F
  CMP EnemyRights, y
  BCS NoCollision
  LDA #$05
  JSR SFX	;game over sound
  JMP GameOver
NoCollision:
  INY	;loop
  CPY #$06
  BEQ NoEnemyCollision
  JMP EnemyCollisionLoop
NoEnemyCollision:

;;; AMMO CODE ;;;

AdjustGunTimer:
  LDA GunTimer
  CMP FiringRate
  BPL LowerTimer
  INC GunTimer
LowerTimer:

MoveAmmoSpriteStart:
  LDA #$00
  STA AmmoMovingLoop
MoveAmmoLoop:
  LDX AmmoMovingLoop
  LDA #$01
  CMP AmmoSpaces, x
  BEQ MoveAmmo
  JMP AmmoMoveDone
MoveAmmo:
  LDA AmmoMovingLoop
  ASL A
  ASL A
  TAX 
  STX AmmSprBaseAdr
  INX
  INX 
  INX
  INC AmmoSprite, x
  INC AmmoSprite, x
  INC AmmoSprite, x
MoveAmmoDone:

CheckIfAmmoInScreen:
  LDA AmmoMovingLoop
  ASL A
  ASL A
  TAX
  INX
  INX
  INX
  LDA AmmoSprite, x
  CMP #$F8	;almost off screen
  BEQ RemoveAmmo
  CMP #$00
  BEQ RemoveAmmo
  JMP AmmoStillOnScreen
RemoveAmmo:
  DEX
  DEX
  LDA #$00
  STA AmmoSprite, x
  LDX AmmoMovingLoop
  LDA #$00
  STA AmmoSpaces, x
  JMP AmmoMoveDone
AmmoStillOnScreen:

AmmoMoveDone:
  INC AmmoMovingLoop
  LDX AmmoMovingLoop
  CPX #$14
  BEQ AllAmmoMoved
  JMP MoveAmmoLoop
AllAmmoMoved:

  LDY #$00
DidAmmoHitEnemyLoop:
  INC Counter
  LDA EnemyInAir, y
  CMP #$01	;well is it even there?
  BEQ StartCheckAmmo
  JMP EnemyStudied
StartCheckAmmo:
  LDA EnemyLefts, y	;check x posses
  STA Temp
  LDX AmmSprBaseAdr
  INX
  INX
  INX
  LDA AmmoSprite, x
  CMP Temp
  BEQ AmmoYCheck
  INC Temp
  CMP Temp
  BEQ AmmoYCheck
  INC Temp
  CMP Temp
  BEQ AmmoYCheck
  INC Temp
  CMP Temp
  BEQ AmmoYCheck
  INC Temp
  CMP Temp
  BEQ AmmoYCheck
  JMP EnemyStudied
AmmoYCheck:
  LDX AmmSprBaseAdr	;check top left
  LDA AmmoSprite, x
  CMP EnemyYPos1, y
  BMI EnemyStudied
  LDA AmmoSprite, x
  CMP EnemyYPos2, y
  BMI AmmoHit
  JMP EnemyStudied
AmmoHit:
  LDA EnemyDmg, y
  STA Temp
  LDX PowerBalance
  DEX
  LDA PowerBalanceToHitPoints, x
  ADC Temp
  STA EnemyDmg, y
  CMP EnemyTotalHitPoints	;is all hit points matched up?
  BMI AmmoHittingSound	;not yet destroyed
  JSR RemoveEnemy	;counter will tell which enemy to destroy
  JSR IncScore
  LDA #$03
  JSR SFX
  LDA PowerBalance
  CMP #$04
  BEQ RemoveHitAmmo
  ASL A
  ASL A
  INC EnemiesDestroyed
  CMP EnemiesDestroyed
  BNE RemoveHitAmmo
  INC PowerBalance
  JSR UpdatePowerLevelSprite
  LDA #$00
  STA EnemiesDestroyed
  JMP RemoveHitAmmo
AmmoHittingSound:
  LDA #$02
  JSR SFX 
RemoveHitAmmo:
  LDX AmmoMovingLoop
  LDA #$00
  STA AmmoSpaces, x
  LDX AmmSprBaseAdr
  INX
  LDA #$00
  STA AmmoSprite, x 
EnemyStudied:
  INY
  CPY #$06
  BEQ EnemiesAllStudied
  JMP DidAmmoHitEnemyLoop
EnemiesAllStudied:

UpdateHighScore1:
  JSR UpdateHighScore
UpdateHighScoreDone:

;;; SPRITE 0 ;;;

DoSprite0:
Sprite0PPU:
  LDA #$00
  STA $2006
  STA $2006
  LDA #$00
  STA $2005
  STA $2005
  LDA #$90
  STA $2000
  LDA #$1E
  STA $2001
WaitNotSprite0:
  LDA $2002
  AND #$40
  BNE WaitNotSprite0
WaitSprite0:
  LDA $2002
  AND #$40
  BEQ WaitSprite0
  LDX #$40
WaitScanline:
  DEX
  BNE WaitScanline
WaitScanlineDone:

EndGame:
  RTI 
  
  
SkipSubroutines:
  LDA #$00
  JMP DoneSubRoutines
  
  .include "subroutines.asm"
  
DoneSubRoutines:




  .bank 1
  .org $E000
  
  .include "data.asm"
  
  .org $FFFA ;first of the three vectors start here
  .dw NMI	;when an NMI happens (once per frame) the processor will jump to the NMI
  .dw RESET	;when the processor first turns on/is reset, it will jump to RESET
  .dw 0	;external interrupt IRQ is not used
  
  .bank 2
  .org $0000
  .incbin "mychrs.chr"	; eventually will be changed to original made graphic file
