extends Node2D

# sources
# https://pmc.ncbi.nlm.nih.gov/articles/PMC1179776/
# something on HIV symptoms
# something on CCR5 alleles

@onready var SceneBackground = $SceneBackground
@onready var SceneText = $PanelContainer/SceneText
@onready var SO = [$SceneOptions/SceneOption1,$SceneOptions/SceneOption2,$SceneOptions/SceneOption3]
@onready var SOT = [$SceneOptions/SceneOption1/PanelContainer/Text,$SceneOptions/SceneOption2/PanelContainer/Text,$SceneOptions/SceneOption3/PanelContainer/Text]

# --------- SCENE DATA STORAGE ------------
# Each scene is a line in data.txt
# Each scene is comprised of:
#	image_id`text`op1_existence`op2_ex`op3_ex`op1_scene`op2_scene`op3_scene`op1_text`op2_text`op3_text`special
@onready var data = FileAccess.open("res://data.txt", FileAccess.READ)
@onready var content = """0`You are born with a heterozygous Δ32 and WT allele combination!``yes```3```Ok``$
1`You are born with 2 homozygous Δ32 alleles!``yes```4```Ok``$
2`You are born with 2 homozygous WT alleles!``yes```5```Ok``$
3`This means that your body will produce both nonfunctional and functional CCR5 receptor proteins.``yes```6```Ok``$
4`This means that your body will only produce nonfunctional CCR5 receptor proteins.``yes```6```Ok``$
5`This means that your body will only produce functional CCR5 receptor proteins.``yes```6```Ok``$
6`Functional CCR5 receptor proteins are able to interface with HIV viruses because of their structure, allowing the virus to inject their genetic material into your cells and infect them. Nonfunctional CCR5 receptor proteins can't connect with HIV viruses since they are structured differently, which prevents them HIV from infecting your cells.`yes``yes`7``21`More info``Onwards!`$
7`These alleles (Δ32 and WT) are just slight variations in the DNA of the genes that are responsible for telling your body how to build the receptor. You have multiple alleles of the same gene because you get one from your mother and one from your father.`yes```8```Ok```[GEN]$
0`In your case, you inherited a Δ32 allele and a WT allele from your parents.``yes```11```Ok``$
1`In your case, you inherited 2 Δ32 alleles from both of your parents.``yes```11```Ok``$
2`In your case, you inherited 2 wild-type alleles from both of your parents``yes```11```Ok``$
11`The DNA of the alleles resides in the nucleus of a cell.```yes```12```Ok`$
12`Each letter in the DNA represents a nucleotide, which are the building blocks of DNA.`yes```13```Ok```$
14`To be read and turned into a protein, it must first undergo transcription and be turned into mRNA by the RNA Polymerase enzyme.``yes```14```Ok``$
15`For example, after transcribing this section of DNA into mRNA, you can see how each A in the DNA is transcribed into U, T into A, C into G, and G into C.```yes```15```Ok`$
13`Here the DNA (blue) and mRNA (black) of the 2 alleles are shown. The Δ32 version differs from the wild-type (WT) allele by 32 nucleotides (red).`yes```16```Ok```$
16`Once complete, mRNA moves outside the nuclear membrane into the cytolplasm where it undergoes translation by a ribosome.``yes```17```Ok``$
17`Each group of 3 nucleotides is a codon which codes for 1 amino acid (in green). The ribosome reads these codons and uses tRNA to assemble the protein from the associated amino acids.```yes```18```Ok`$
18`The protein then folds into a structure based on the sequence of amino acids that makes it up`yes```19```Ok```$
18`For a Δ32 allele, since it was missing 32 nucleotides and about 11 amino acids, the protein it codes for has a different shape compared to the WT allele and is nonfunctional.``yes```20```Ok``$
6`This process creates your CCR5 receptor protein, which influences your resistance to HIV!```yes```21```Onwards!`$
21`Throughout the first 30 years of your life, you were...`yes`yes`yes`22`23`24`Hard working`Kind`Fashionable`$
22`At some point, an HIV virus entered your body (probably from your parents) ...``yes```25```Ok``[+HARD][GEN]$
22`At some point, an HIV virus entered your body (probably from your parents) ...``yes```25```Ok``[GEN]$
22`At some point, an HIV virus entered your body (probably from your parents) ...``yes```25```Ok``[+FASHION][GEN]$
0`But thanks to your body's alleles, you were largely able to resist infection!``yes```28```Hooray``$
1`But thanks to your body's alleles, you were able to resist infection!``yes```28```Yay``$
2`And successfully infected you.``yes```28```Uh-oh``$
28`You sadly did not make many friends as a child.``yes```29```Huh...``$
29`However, now that you are graduating from elementary school, your parents present you with 1 choice for lower school: Henry Addams Middle School (HAMS).`yes```30``###`HAMS!``Janilton...?`$
30`Henry Addams Middle School, or HAMS, is a well-respected public institution known for its rigorous and prestigious academic curriculum and qualified teachers.``yes```31```Ok``$
30`At this school, you can expect to meet some hard-working and focused students and make lifelong connections.``yes```32```Great!``$
30`On the first day of school...``yes```33```Go on...``[RAN]$
33`You meet a girl licking a popsicle!`yes`yes`yes`36`42`37`Bully her`Ok`Befriend her`$
34`You meet a guy playing basketball!`yes`yes`yes`38`42`39`Bully him`Ok`Befriend him`$
35`You meet a guy wearing a top hat!`yes`yes`yes`40`42`41`Bully him`Ok`Befriend him`$
33`She starts crying after you made fun of her for eating a popsicle on a cold day.``yes```42```Deserved``[-POPSICLE]$
33`She laughs at your joke and offers you a popsicle. She tells you she only gives popsicles to people who are cool and that her name is Sadie.`yes``yes`42``42`No thanks``Yum!`[+POPSICLE]$
34`You make fun of him for missing 23 times in a row. He drops the basketball and runs away. You can hear his crying grow fainter and fainter as he gets farther away.``yes```42```Haha``[-BASKETBALL]$
34`You give him a few pointers about basketball and demonstrate how to shoot. He finally gets his first hoop and high fives you. He tells you that he loves basketball but sucks at it. And that his name is Bob.``yes```42```Good job Bob!``[+BASKETBALL]$
35`You make fun of him by comparing him to Abraham Lincoln. He immediately starts crying and mumbling something about his mom.              She isn't here to hear him.``yes```42```Haha``[-TOPHAT]$
35`You compliment his top hat. He immediately smiles and says thank you. He explains that his dead mom gave him the hat as a parting gift and that his name is Joe.``yes```42```Nice to meet you``[+TOPHAT]$
29`Time passes...``yes```43```...``$
29`Halfway through the school year...``yes```44```What?``[GEN]$
21`You start feeling sick.``yes```47```Call the doctor!``$
21`Nothing happens.``yes```48```Anticlimactic.``$
46`You start experience rapid weight loss, frequent infections, constant fatigue, rashes, and other not-great symptoms.``yes```47```Doctor!``$
47`Luckily, the doctor gives you some antiretroviral treatment prescriptions and therapy and after a long time you start to feel better``yes```48```Awesome!``$
48`Now you are 32 and you are getting married``yes```49```Ok``$
49`To determine the possible alleles and vulnerability to HIV of your children, we should first analyze your past family tree. In this tree, the allele combination and phenotype (trait) of each family member is shown.``yes```50```Ok``$
50`The gene for the CCR5 receptor allele (which influences HIV resistance) is found on chromosome 3, position 3p21`yes```51```Ok```$
51`Each of your grandparents has 2 copies of chromosone 3, each with an allele for the CCR5 receptor.``yes```52```Ok``$
52`Since a child inherits 1 copy of chromosome 3 from each parent, there would be 2 options of which allele they would inherit from each parent```yes```53```Ok`$
53`This can be represented with a egg sperm chart or Punnett Square that can be used to find the probability of each allele combination and trait.`yes```54```Ok```$
53`Each row/column represents the inheritance of a specific allele from one parent``yes```55```Ok``$
54`Here is the egg sperm chart for your grandparents, with the alleles that your mom had circled. ```yes```56```Ok`$
55`Here is the egg sperm chart for your parents, with the alleles of your two siblings circled in red and the probabilities of each allele combination (trait) displayed.`yes```57```Ok```$
69`Now it's your turn!``yes```58```Ok``$
56`Before you can reproduce, you must first produce sex cells ```yes```59```Ok`$
57`During this process, genetic variation increases through homologous chromosomes (chromosomes that contain the same genes) "crossing over"`yes```60```Ok```$
57`Crossing over is when homologous chromosomes exchange bits of themselves with each other``yes```61```Ok``$
57`This is possible since they contain the same genes but potentially different alleles. Crossing over can make new combinations of alleles on a chromosome, increasing genetic variation ```yes```62```Ok`$
58`As the process of forming sex cells continues...`yes```63```Ok```$
59`Your chromosomes eventually line up to be divided up into cells.``yes```64```Ok``$
59`Homologous pairs line up randomly. ```yes```65```Ok`$
59`This is called independent assortment, which randomizes the combination of chromosomes in each resulting sex cell and increases genetic diversity.`yes```66```Ok```$
60`Another cause of genetic variation are random mutations caused by various environmental effects (like UV radiation), which changes the DNA of some genes and the resulting traits``yes```67```Ok``$
61`The last cause of genetic variation is random fertilization, where the sex cells (sperm and egg) that form the child are randomly selected.```yes```68```Ok`$
61`The baby is...``yes```69```. . .``[IHR]$
0`Heterozygous!``yes``````Ok...``$
0`However, this isn't the singular factor in your child's exposure to HIV``yes```75```What else?``$
1`Homozygous for Δ32!``yes``````Ok...``$
1`However, this isn't the singular factor in your child's exposure to HIV``yes```75```What else?``$
2`Homozygous for WT!``yes``````Ok...``$
2`However, this isn't the singular factor in your child's exposure to HIV``yes```75```What else?``$
73`Environmental factors, like access to healthcare or good nutrition, can also influence the strength of HIV symptoms``yes``````And...``$
74`Most complex traits are also polygenic, which means multiple genes influence the trait. So, the CCR5 gene would not solely determine HIV vulernability``yes```78```Cool``[GEN]$
0`But anyway, this story will end here, with the next generation just born...``````````$
1`But anyway, this story will end here, with the next generation just born...``````````$
2`But anyway, this story will end here, with the next generation just born...``````````$
$
$
$
$
$
$
$
$
$
$
$
$
$
$
$
$
$
$
$
$
$
100`Welcome!``yes``````Hi... ?``$
100`In this visual-novel style game you will learn the answer to the question...``yes``````What?``$
100`Why and how are we different and the same!``yes``````Ok``$
100`Have fun!``yes```0```Of course!``[GEN]$""".split("\n")#Array(data.get_as_text().split("\n")) # array element for each line

@onready var gene = randi_range(0,2) # random genotype
var active_scene = -1

var opinions = {"popsicle":0, "basketball":0, "tophat":0, "ponytail":0, "glasses":0, "baseball":0, "ninja":0, "sunglasses":0, "fashion":0, "hard":0}

func _ready():
	var new_content = content
	content = []
	for i in range(0, len(new_content)):
		content.append(new_content[i].split("`")) # scene id = placement in the array
	active_scene = gene
	load_scene(101)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func o1down():
	load_scene(int(content[active_scene][5])) if int(content[active_scene][5]) else load_scene(active_scene + 1)
func o2down():
	load_scene(int(content[active_scene][6]))if content[active_scene][6] != "" else load_scene(active_scene + 1)
func o3down():
	load_scene(int(content[active_scene][7]))if int(content[active_scene][7]) else load_scene(active_scene + 1)

func load_scene(id):
	if content[active_scene][11]: # special events
		if content[active_scene][11].contains("[RAN]"):
			id += randi_range(0,2)
		if content[active_scene][11].contains("[GEN]"):
			id += gene
		if content[active_scene][11].contains("[IHR]"):
			match randi_range(0, 1):
				0: # delta32
					match gene:
						0:
							match randi_range(0,1):
								0:
									id += 1
								1:
									pass
						1:
							id += 1
						2:
							pass
				1: # wt
					match gene:
						0:
							match randi_range(0,1):
								0:
									pass
								1:
									id += 2
						1:
							pass
						2:
							id += 2
	
	active_scene = id
	
	# actions with data
	for key in opinions:
		#print(str(active_scene) + " content: " + str(content[active_scene]))
		#print(content[active_scene])
		#print(content[active_scene][11])
		if content[active_scene][11].contains("[+" + key.to_upper() + "]"):
			opinions[key] += 1
		if content[active_scene][11].contains("[-" + key.to_upper() + "]"):
			opinions[key] -= 1
	
	# setting up the images
	SceneBackground.texture = load('res://sprites/' + str(content[id][0])+'.png')
	SceneText.text = center(content[id][1])
	for i in range(len(SOT)):
		SOT[i].text = center(content[id][i+8])
	for i in range(len(SO)):
		SO[i].set_disabled(true)
		if content[id][i+2] == "yes":
			SO[i].set_disabled(false)

func center(text):
	return "[center]" + text + "[/center]"
