---
layout: page
section: navbar
permalink: /notes/
---

{% for note in site.documents %}
  [{{ note.title }}]({{ note.url }})
{% endfor %}
