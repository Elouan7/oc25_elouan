//var message = "Bienvenue";


// console.log("message");


//function ma_fonction() {
//    console.log("ma fonction");
//}


//ma_fonction();


//console.log(document.getElementById("bienvenue").textContent);


//for (var i = 0; i < 10; i++) {
//    console.log(i);
//}

//function ajouterPersonnage() {
//    var mon_perso = "Jean";

//    var nouveau_li = document.createElement("li");
//    var nouveau_texte = document.createTextNode(text_perso);


//    console.log("perso");
//}



var jean = {
    nom: 'Jean',
    classe: 'guerrier',
    niveau: 2,
    passer_niveau: function() {
        this.niveau++;
    }
}

console.log(jean);
console.log(jean.classe);
jean.passer_niveau();
console.log(jean.niveau);

function creer_personnage(nom, classe, niveau) {
    var nouveau_personnage = {
        nom: nom,
        classe: classe,
        niveau: niveau,
        passer_niveau: function() {
            this.niveau++;
        },
        creer_li: function() {
            var li_personnage = document.createElement("li");
            var texte_personnage = document.createTextNode(this.nom);
            li_personnage.appendChild(texte_personnage);
            return li_personnage;
        }
    };
    return nouveau_personnage;
}

var nicole = creer_personnage('Nicole', 'voleur', 3);

console.log(nicole);


var troupe = [

    creer_personnage('Rhoshandiatelly-neshiaunneveshenk Koyaanfsquatsiuty Williams', 'guerrier', 2),
    creer_personnage('nicole', 'voleur', 3),
    creer_personnage('matteo', 'mage', 5),
    creer_personnage('jean-michel', 'archer', 4),
    creer_personnage('lara', 'soigneur', 1),
    creer_personnage('paul', 'paladin', 6),
    creer_personnage('sophie', 'druide', 2),
    creer_personnage('thomas', 'barbare', 3),
    creer_personnage('emma', 'assassin', 4),
    creer_personnage('lucas', 'nécromancien', 5),
    creer_personnage('chloé', 'ensorceleuse', 2),
    creer_personnage('maxime', 'berserker', 3)
];

console.log(troupe);
console.log(troupe[0]);

for (var i = 0; i < troupe.length; i++) {
    console.log(troupe[i].nom + " le " + troupe[i].classe + " est au niveau " + troupe[i].niveau);
}

//appendChild --> relier deux éléments HTML entre eux
for (var i = 0; i < troupe.length; i++) {   
    var perso = troupe[i];
    var li_personnage = document.createElement("li");
    var texte_personnage = document.createTextNode(perso.nom + " le " + perso.classe + " (niveau " + perso.niveau + ")");
    li_personnage.appendChild(texte_personnage);
    var liste_perso = document.getElementById("liste-personnages");
    liste_perso.appendChild(li_personnage);
}