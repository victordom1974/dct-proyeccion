<!--
Last modified: 2026-10-10
Changelog:
- 2026-10-10: Add section on getting the MATLAB Online account through the UPNA
  campus licence; fix stray asterisks at the end of the file.
-->

# Proyección ortogonal e imágenes

Material creado para la asignatura **Matemáticas I (251101)** del Grado en Ingeniería
en Diseño Mecánico de la Universidad Pública de Navarra (UPNA), campus de Tudela.
Tema 3: Ortogonalidad.

Demo de clase: una imagen es un vector de $\mathbb{R}^N$ (o de $\mathbb{R}^{3N}$ en color).
Escribimos sus coordenadas en la base ortonormal de la DCT, nos quedamos con las $k$
mayores y reconstruimos. Eso es exactamente la **proyección ortogonal** sobre el
subespacio generado por esos $k$ vectores de la base: la mejor aproximación posible con
$k$ coeficientes. Es la idea matemática que hay detrás de JPEG.

## Antes de empezar: tu cuenta de MATLAB (solo la primera vez)

La UPNA tiene licencia de campus de MATLAB, que incluye **MATLAB Online**: se usa desde
el navegador, sin instalar nada.

1. Entra en el [portal de MATLAB de la UPNA](https://es.mathworks.com/academia/tah-portal/universidad-publica-de-navarra-31195799.html).
2. Pulsa **«Inicie sesión para comenzar»** e inicia sesión, o crea una cuenta de
   MathWorks si no la tienes, **con tu correo de la universidad**.
3. Listo: tu cuenta queda asociada a la licencia de la UPNA y ya puedes usar los
   botones de abajo.

## Abrir en MATLAB Online

| Script | Qué hace |
|---|---|
| [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=victordom1974/dct-proyeccion&file=comprensionFoto.m) `comprensionFoto.m` | Elige una imagen y el modo (gris o color), mira sus coordenadas DCT, decide qué porcentaje conservar y compara original y reconstrucción. |
| [![Open in MATLAB Online](https://www.mathworks.com/images/responsive/global/open-in-matlab-online.svg)](https://matlab.mathworks.com/open/github/v1?repo=victordom1974/dct-proyeccion&file=baseDCT.m) `baseDCT.m` | Dibuja la base DCT de un bloque $8\times 6$: primero como imágenes, luego como lo que son, vectores de $\mathbb{R}^{48}$. Comprueba que es ortonormal. |

**No hace falta saber nada de MATLAB ni entender el código**: solo pulsar botones.

## Cómo usarlo, paso a paso

1. **Pulsa uno de los dos botones** de la tabla. Se abre MATLAB Online en el navegador.
   Si te pide iniciar sesión, usa la cuenta de MathWorks que asociaste a la UPNA
   (ver [Antes de empezar](#antes-de-empezar-tu-cuenta-de-matlab-solo-la-primera-vez)).
   Si pregunta si quieres copiar (*clone*) el repositorio, di que sí: se copia en tu
   MATLAB Drive, es tuyo y no estropeas nada aunque lo cambies.
2. **Se abre el script en el editor** (un texto lleno de código: no hace falta leerlo).
   Arriba, en la pestaña **EDITOR**, pulsa el botón verde **Run** (▶).
3. **Con `baseDCT.m`** no tienes que hacer nada más: aparecen dos ventanas con los 48
   vectores de la base, primero como imágenes y luego como vectores.
4. **Con `comprensionFoto.m`** el programa te va preguntando con ventanitas:
   - elige una imagen (las tres de ejemplo están ya en la carpeta);
   - elige *Grayscale* (gris) o *Colour* (color);
   - ves la imagen original; pulsa **OK** para seguir;
   - ves la imagen como vector y sus coordenadas en la base DCT; escribe **qué
     porcentaje de coeficientes quieres conservar** (por ejemplo 5) y pulsa **OK**;
   - ves la reconstrucción junto al original, con el error cometido.
5. **Vuelve a pulsar Run** para probar con otro porcentaje (1, 0.5, 20...) y comparar.

**Con tus propias fotos:** en el panel de la izquierda (*Files*), pulsa el botón de
subir ficheros (*Upload*) y súbelas a la misma carpeta. Luego elígelas en el paso 4.
Mejor fotos no muy grandes (hasta unos 1000 píxeles de lado): las del móvil, redúcelas
antes o tardará bastante.

## Imágenes incluidas

- `starryNight.jpg`: Vincent van Gogh, *La noche estrellada* (1889), MoMA. Dominio público.
- `hombreArbol.jpg`: El Bosco, *El jardín de las delicias* (detalle del hombre-árbol),
  Museo del Prado. Dominio público.
- `cabezo-castildetierra.jpg`: Castildetierra, Bardenas Reales (Navarra). Fotografía propia
  del autor del repositorio, distribuida bajo licencia [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/deed.es).
