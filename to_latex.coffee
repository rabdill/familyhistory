parser = require 'parse-gedcom'
fs = require 'fs'
_ = require 'lodash'
sources = require './sources'
config = require './config'

previous_footnote = null

formatting =
  census: (r) ->
    if r.included is true
      "#{r.year} U.S. census, #{r.county} Co., #{r.state}, #{r.division}, dwell. #{r.dwelling}, fam. #{r.family}; #{r.of_interest}."
    else
      r.included = true
      result = "#{r.year} U.S. census, #{r.county} County, #{r.state}, population schedule, #{r.division}, p. #{r.page}, dwelling #{r.dwelling}, family #{r.family}; #{r.of_interest}; image, Ancestry.com (\\url{#{r.url}} : accessed #{r.accessed})"
      result += "; citing FHL microfilm #{r.microfilm}" if r.microfilm?
      result += "."
  findagrave: (r) ->
    if r.included is true
      "\\textit{Find A Grave}, memorial #{r.number}; #{r.names}; gravestone added by #{r.credit}."
    else
      r.included = true
      "\\textit{Find A Grave}, database with images (\\url{https://www.findagrave.com/cgi-bin/fg.cgi?page=gr&amp;GRid=#{r.number}} : accessed #{r.accessed}), memorial #{r.number}; #{r.names}; #{r.cemetery}, #{r.location}; gravestone added by #{r.credit}."
  church_record: (r) ->
    if r.included is true
      "#{r.author}, ``#{r.title},\" #{r.entry}."
    else
      "#{r.author}. ``#{r.title},\" database with images, \\textit{Ancestry.com}, (\\url{#{r.url}} : accessed #{r.accessed}), #{r.entry}#{if r.citing then "; " + r.citing + "." else ""}."

getSourceString = (title) ->
  if sources[title] is previous_footnote
    answer = "\\footnote{Ibid.}"
  else
    if formatting[sources[title].type]
      answer = "\\footnote{#{formatting[sources[title].type] sources[title]}}"
    else
      answer = "\\footnote{unrecognized reference type.}"
  previous_footnote = sources[title]  # this comes after the call to format it because the item may be modified
  answer


cite = (fact) ->
  results = ''
  if fact?.citation?.length
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
      \\item[Birth] #{person.birth?.date.value}#{if person.birth?.date.value and person.birth?.place.value then ',' else ''}#{cite person.birth?.date}#{if person.birth?.date.value and person.birth?.place.value then ' ' else ''}#{person.birth?.place.value}#{cite person.birth?.place}
      \\item[Death] #{person.death?.date.value}#{if person.death?.date.value and person.death?.place.value then ',' else ''}#{cite person.death?.date}#{if person.death?.date.value and person.death?.place.value then ' ' else ''}#{person.death?.place.value}#{cite person.death?.place}
      \\item[Spouse] #{person.spouse?.name?.value or 'unknown'}#{if person?.spouse?.name?.value then ' \\textit{' + person.generation + '-' + (person.number + 1) + '}' else ''}#{cite person.spouse?.name}#{if person.spouse.date?.value then ", married " + person.spouse.date.value else ""}#{cite person.spouse?.date or ""}
      \\item[Father] #{person.father or 'unknown'}#{if person.father then ' \\textit{' + (person.generation + 1) + '-' + (person.number * 2) + '}' else ''}
      \\item[Mother] #{person.mother or 'unknown'}#{if person.mother then ' \\textit{' + (person.generation + 1) + '-' + ((person.number * 2) + 1) + '}' else ''}
  """

  if Object.keys(person.residence or {}).length
    results += """
\n
      \\item[Residence]\\mbox{}
          \\begin{description}
"""
    for year, info of person.residence
      results += "\n            \\item[#{year}] #{info.place}#{if info.address then " (" + info.address + ")" else ""}#{cite info}"
    results += "\n        \\end{description}"

  if person.children?.length
    results += """
\n
    \\item[Children]\\mbox{}
        \\begin{itemize}
"""
    for child in person.children
      results += "\n            \\item #{child.value}"
      if child.direct_ancestor
        results += " \\textit{#{person.generation - 1}-#{if person.number % 2 is 0 then (person.number / 2) else ((person.number - 1) / 2)}}"
      results += "#{cite child}"
    results += "\n        \\end{itemize}"
  

  results += "\n\\end{description}"
  if person.bio then results += "\n\n\\paragraph #{person.bio}"
  results += "\n\n"

template = fs.readFileSync('template.tex').toString()
combined = template.replace '*****TITLE_GOES_HERE*****', config.title
combined = combined.replace '*****AUTHOR_GOES_HERE*****', "By #{config.author}"
combined = combined.replace '*****FAMILY_GOES_HERE*****', results
fs.writeFileSync 'results.tex', combined