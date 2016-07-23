people = require './people'
fs = require 'fs'
results = ""

findSpouse = (number) ->
  target = if number % 2 is 0 then number + 1 else number - 1
  for person in people
    return person if person.number is target

findKid = (number) ->
  target = if number % 2 is 0 then number / 2 else (number - 1) / 2;
  for person in people
    return person if person.number is target

findDad = (number) ->
  target = number * 2;
  for person in people
    return person if person.number is target

findMom = (number) ->
  target = (number * 2) + 1;
  for person in people
    return person if person.number is target

printPerson = (person) ->
  if person then "#{person.name} \\textit{#{person.generation}-#{person.number}}" else 'unknown'

for person in people
  person.spouse = findSpouse person.number
  person.dad = findDad person.number
  person.mom = findMom person.number
  person.kid = findKid person.number

  results += """
  \\person{#{person.name}}{#{person.generation}-#{person.number}}
  \\begin{description}
      \\item[Birth]
      \\item[Death]
      \\item[Spouse] #{printPerson person.spouse}
      \\item[Father] #{printPerson person.dad}
      \\item[Mother] #{printPerson person.mom}
      \\item[Residence]\\mbox{}
          \\begin{description}
              \\item[1900] somewhere
          \\end{description}
      \\item[Children]
          \\begin{description}
              \\item[with #{if person.spouse then person.spouse.name else 'spouse'}]\\mbox{}
                  \\begin{itemize}
                      \\item #{printPerson person.kid}
                  \\end{itemize}
          \\end{description}
  \\end{description}


  \\paragraph lalala
  """

fs.writeFileSync 'results.tex', results