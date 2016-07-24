parser = require 'parse-gedcom'
fs = require 'fs'
_ = require 'lodash'
sources = require './sources'

formatting =
  census: (r) ->
    if r.included is true
      "#{r.year} U.S. census, #{r.county} County, #{r.state}, #{r.division}, dwell. #{r.dwelling}, fam. #{r.family}; #{r.of_interest}."
    else
      r.included = true
      "#{r.year} U.S. census, #{r.county} County, #{r.state}, population schedule, #{r.division}, p. #{r.page}, dwelling #{r.dwelling}, family #{r.family}; #{r.of_interest}; image, Ancestry.com (#{r.url} : accessed #{r.accessed}); citing FHL microfilm #{r.microfilm}."

getSourceString = (title) ->
  "\\footnote{#{formatting[sources[title].type] sources[title]}}"


cite = (fact) ->
  results = ''
  if fact.citation?.length
    for citeRef, index in fact.citation
      results += getSourceString citeRef
      if fact.citation.length - 1 isnt index # if it's not the last one
        results += '\\textsuperscript{,}' 
  else
    results = ''
  results



processed = JSON.parse fs.readFileSync('interim.json').toString()
included = _.sortBy _.filter(processed, 'number'), 'number'


# WRITE THE LATEX FILE
results = ''

for person in processed when person.number
  results += """
  \\person{#{person.name}}{#{person.generation}-#{person.number}}
  \\begin{description}
      \\item[Birth] #{person.birth?.date.value}#{if person.birth?.date.value and person.birth?.place.value then ', ' else ''}#{cite person.birth?.date}#{person.birth?.place.value}#{cite person.birth?.place}
      \\item[Death] #{person.death?.date.value}#{if person.death?.date.value and person.death?.place.value then ', ' else ''}#{cite person.death?.date}#{person.death?.place.value}#{cite person.death?.place}
      \\item[Spouse] #{person.spouse.value or 'unknown'}#{if person.spouse.value then ' \\textit{' + person.generation + '-' + (person.number + 1) + '}' else ''}
      \\item[Father] #{person.father or 'unknown'}#{if person.father then ' \\textit{' + (person.generation + 1) + '-' + (person.number * 2) + '}' else ''}
      \\item[Mother] #{person.mother or 'unknown'}#{if person.mother then ' \\textit{' + (person.generation + 1) + '-' + ((person.number * 2) + 1) + '}' else ''}
      \\item[Residence]\\mbox{}
          \\begin{description}
              \\item[1900] somewhere
          \\end{description}
      \\item[Children]
          \\begin{itemize}
              \\item 
          \\end{itemize}
  \\end{description}


  \\paragraph lalala



  """

template = fs.readFileSync('template.tex').toString()
combined = template.replace '*****FAMILY_GOES_HERE*****', results
fs.writeFileSync 'results.tex', combined