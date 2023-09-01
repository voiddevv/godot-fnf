extends Node
class_name ModConfig

@export_group("General Info")
@export_placeholder("No title provided") var title:String = "Friday Night Funkin'"
@export_multiline var description:String = "The vanilla game up to Week 7, all in a mod!"
@export var icon:CompressedTexture2D = preload("res://assets/images/default_mod_icon.png")

@export_group("Mod Info")
@export var api_version:String = "0.1.0"
@export var mod_version:String = "0.1.0"

@export_subgroup("Author Info")
@export var contributors:ContributorList = ContributorList.new()
