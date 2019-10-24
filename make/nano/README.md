nano
====

**Nano** ist ein kleiner Texteditor für die Konsole, der aber im
Gegensatz zu (n)vi eine Bedienung wie ein normaler Editor (z.B. der
Windows-Editor) besitzt. Es ist also nicht erforderlich viel Kommandos
zu lernen, bevor man ihn nutzen kann. Daher ist er für Anfänger und
User, die nicht des 10-Finger-Systems mächtig sind, oftmals weit besser
geeignet als vi.

Damit man die Pos1 und Home Tasten auch in Nano benutzen kann ist
(zumindest bei mir in der Kombination putty / Windows) das Setzen der
Umgebungsvariable TERM hilfreich:

```
export TERM=xterm
```

in der rc.custom tut den Trick.

