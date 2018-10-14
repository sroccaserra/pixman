## Démo

- <a href="https://sroccaserra.github.io/pixman" target="_blank" rel="noopener noreferrer">https://sroccaserra.github.io/pixman</a>

## Dev (version PICO-8)

Version [PICO-8][pico-8].

Pour démarrer, créer un fichier `.env` sur le modèle de `.env.example` qui indique où se trouve votre exécutable `pico8`. Ce fichier `.env` ne sera pas versionné.

Ensuite, lancer PICO-8 avec :

```
make start-pico8
```

Une fois PICO-8 lancé, vous pouvez charger et lancer la cartouche :

```
load pixman.p8
run
```

Voir aussi :


## WIP : version TIC-80

La version PICO-8 est en cours de portage vers [TIC-80][tic-80].

[pico-8]: https://www.lexaloffle.com/pico-8.php
[tic-80]: https://tic.computer/
