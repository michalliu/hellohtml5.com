---
layout: page
permalink: /notes/
---

{% for note in site.documents %}
  [{{ note.title }}]({{ note.url }})
{% endfor %}
