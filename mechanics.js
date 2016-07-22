var results = "";

function findSpouse(number) {
  target = number % 2 === 0 ? number + 1 : number - 1;
  for(var i=0; i < people.length; i++) {
    if(people[i].number === target) return people[i];
  }
};

function findKid(number) {
  target = number % 2 === 0 ? number / 2 : (number - 1) / 2;
  for(var i=0; i < people.length; i++) {
    if(people[i].number === target) return people[i];
  }
};

function findDad(number) {
  target = number * 2;
  for(var i=0; i < people.length; i++) {
    if(people[i].number === target) return people[i];
  }
};

function findMom(number) {
  target = (number * 2) + 1;
  for(var i=0; i < people.length; i++) {
    if(people[i].number === target) return people[i];
  }
};

for(var i=0; i < people.length; i++) {
  results += "\n\\person{" + people[i].name + "}{" + people[i].generation + "-" + people[i].number + "}"
  results += "\n\\begin{description}\n  \\item[Birth]\n  \\item[Death]\n  \\item[Spouse] ";

  spouse = findSpouse(people[i].number);
  results += spouse ? spouse.name + " \\textit{" + spouse.generation + "-" + spouse.number + "}" : "unknown";

  results += "\n  \\item[Father] "
  dad = findDad(people[i].number);
  results += dad ? dad.name + " \\textit{" + dad.generation + "-" + dad.number + "}" : "unknown";

  results += "\n  \\item[Mother] "
  mom = findMom(people[i].number);
  results += mom ? mom.name + " \\textit{" + mom.generation + "-" + mom.number + "}" : "unknown";

  if(people[i].number % 2 === 0) {
    results += "\n  \\item[Children]\n    \\begin{description}\n      \\item[with "
    results += spouse ?  spouse.name : "spouse"
    results += "]\\mbox{}\n        \\begin{itemize}\n          \\item ";
    kid = findKid(people[i].number);
    results += kid.name + " \\textit{" + kid.generation + "-" + kid.number + "}\n        \\end{itemize}\n    \\end{description}"
  }
  results += "\n  \\item[Residence]\\mbox{}\n    \\begin{description}\n      \\item[1900] somewhere\n    \\end{description}\n\\end{description}\n\n\\paragraph lalala\n\n\n"

}

document.getElementById('info').innerHTML = results;
