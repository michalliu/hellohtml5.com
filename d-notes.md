---
layout: page
title: 笔记
permalink: /notes/
---

{% for note in site.documents %}
  [{{ note.title }}]({{ note.url }})
{% endfor %}
