extends Node2D
@onready var meterP1: TextureProgressBar = $MeterP1
@onready var meterP2: TextureProgressBar = $MeterP2
@onready var p1Stocks: GridContainer = $P1Stocks
@onready var p2Stocks: GridContainer = $P2Stocks
@onready var p1Glove: TextureRect = $P1Stocks/BoxingGlove
@onready var p2Glove: TextureRect = $P2Stocks/BoxingGlove
@onready var p1Percent: RichTextLabel = $PercentageP1
@onready var p2Percent: RichTextLabel = $PercentageP2

var p1GloveTexture: Texture2D
var p2GloveTexture: Texture2D


func _ready() -> void:
	p1GloveTexture = load("res://Assets/Sprite Sheets/ORB_glove.png")
	p2GloveTexture = load("res://Assets/Sprite Sheets/BLOC_glove.png")
func _process(delta: float) -> void:
	meterP1.value = lerp(meterP1.value, PlayerData.P1_Damage, 0.1)
	meterP2.value = lerp(meterP2.value, PlayerData.P2_Damage, 0.1)
	
	if PlayerData.P1_Damage <= 0:
		p1Percent.text = "0%"
	else:
		p1Percent.text = str(int(round(PlayerData.P1_Damage))) + '%'
	if PlayerData.P2_Damage <= 0:
		p2Percent.text = "0%"
	else:
		p2Percent.text = str(int(round(PlayerData.P2_Damage))) + '%'
	
	## PLAYER 1 STOCK STUFF
	if (p1Stocks.get_child_count() < PlayerData.P1_Stock):
		var p1StockGlove: TextureRect = TextureRect.new()
		p1StockGlove.texture = p1GloveTexture
		p1Stocks.add_child(p1StockGlove)		
	if (p1Stocks.get_child_count() > PlayerData.P1_Stock):
		p1Stocks.remove_child(p1Stocks.get_child(p1Stocks.get_child_count() - 1))

	## PLAYER 2 STOCK STUFF
	if (p2Stocks.get_child_count() < PlayerData.P2_Stock):
		var p2StockGlove: TextureRect = TextureRect.new()
		p2StockGlove.texture = p2GloveTexture
		p1Stocks.add_child(p2StockGlove)		
	if (p2Stocks.get_child_count() > PlayerData.P2_Stock):
		var anim_player: AnimationPlayer = p2Stocks.get_child(p2Stocks.get_child_count() - 1).get_child(0)
		anim_player.play("stock_anim")
		p2Stocks.remove_child(p2Stocks.get_child(p2Stocks.get_child_count() - 1))
