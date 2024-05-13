# Uso de escenas

He considerado añadir escenas a todos los objectos, para facilitarlo y añadirlos de forma estática

Tras muchos quebraderos de cabeza tomo los siguientes convenios:
    - Generar id con export para identificar el objecto.id y que coincida con el objeto.name. De esta forma puedo añadirlos en editor visual de forma estática sin volverme loco
    - Crear una funcion que se llame initialize en cada objeto para iniciar parametros que no sean id logicamente. Esto simplifica todo mucho
