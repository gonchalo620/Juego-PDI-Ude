%--------------------------------------------------------------------------
%------- JUEGO PDI ----------------------------------------------
%------- Coceptos básicos de PDI-------------------------------------------
%------- Por: Gonzalo Andrés García C    gandres.garcia@udea.edu.co -------
%-------      Marcell Piravique   gandres.garcia@udea.edu.co -------
%-------      Estudiantes de Ingenieria de Sistemas UdeA
%-------      -------------------------------------------------------------
%-------        PROFESOR DEL CURSO
%-------      David Fernández    david.fernandez@udea.edu.co --------------
%-------      Profesor Facultad de Ingenieria BLQ 21-409  -----------------
%-------      CC 71629489, Tel 2198528,  Wpp 3007106588 -------------------
%------- Curso Básico de Procesamiento de Imágenes y Visión Artificial-----
%------- V2 Abril de 2015--------------------------------------------------
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
%--1. Inicializo el sistema -----------------------------------------------
%--------------------------------------------------------------------------


clear all   % Inicializa todas las variables
close all   % Cierra todas las ventanas, archivos y procesos abiertos
clc         % Limpia la ventana de comandos

% estos comandos se pueden hacer en la consola de comandos para ver información
%a cerca de los dispositivos y plugins necesarios para la camara
%  imaqhwinfo
%  imaqhwinfo('winvideo')
%  imaqhwinfo('winvideo',1)
%  imaqtool para ver un preview en las camaras que tengamos


%--------------------------------------------------------------------------
%-- 2. Definición de variables --------------------------------------------
%--------------------------------------------------------------------------


global numCol; %Numero de pixeles de ancho por rectángulo
global numFil;%Numero de pixeles de alto por rectángulo
global contador; %variable contador para definir la duración del rectangulo en la misma posicion
global x; %coordenada en x aleatoria para dibujar el rectángulo
global y;%coordenada en y aleatoria para dibujar el rectángulo
global xCent; %coordenada en x del centroide de los objetos rojos
global yCent;%coordenada en y del centroide de los objetos rojos
global ganadas; %variables para contar las ganadas que hayamos realizado
global perdidas;%variables para contar las perdidas que hayamos realizado
global maxPuntos; % variable para definir el numero de puntos maximos para acabar el juego

numCol=80;%porque 640/8=80
numFil=60;%porque 480/8=60
contador=0;
ganadas=0;
perdidas=0;
maxPuntos=15;


%--------------------------------------------------------------------------
%-- 3. Configuracion de la captura de video -------------------------------
%--------------------------------------------------------------------------


vid=videoinput('winvideo',1,'YUY2_640x480');% Se captura un stream de video usando videoinput, con argumento
% Se configura las opciones de adquision de video
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')%la imagen del video se van a tomar en modo RGB,
vid.FrameGrabInterval = 1;%framegrabinterval significa que tomara cada 1 frame del stream de video adquirida
start(vid)%con start(vid) se activa la adquisicion de video


%--------------------------------------------------------------------------
%-- 4. Inicio de funciones --------------------------------------------
%--------------------------------------------------------------------------


% creamos un bucle while mientras perdidas o ganadas no haya llegado al
% numero maximo de puntos
%while(vid.FramesAcquired<=200)
while(perdidas<maxPuntos && ganadas <maxPuntos)%Mientras nadie haya llegado al maximo de puntos
    
    
%--------------------------------------------------------------------------
%-- 5. Captura de Imagen del video --------------------------------------------
%--------------------------------------------------------------------------
    
    % se toma una snapshot del stream y se la almacena en imagen para trabajar mas facil
    imagen = getsnapshot(vid);
    imagen = flip(imagen,2);%creamos efecto espejo
    [fil,col,cap]=size(imagen);%tamaño de fila, columna y capas
    
%--------------------------------------------------------------------------
%-- 6. Funciones para reconocer el color rojo en la imagen ----------------
%--------------------------------------------------------------------------
    
    
    % tenemos que extraer el color rojo
    % de la imagen en escala de grises de la imagen adquirida en imagen
    diff_im = imsubtract(imagen(:,:,1), rgb2gray(imagen));%imsubstract resta las matrices, sirve para sacar algun valor constante de una imagen, usamos como
    %argumento el array de imagen y la funcion rgb2gray de imagen
    
    
    %se usa medfilt2 para filtrar la senial del ruido
    diff_im = medfilt2(diff_im, [3 3]);%medfilt2(A, [m n])realiza el filtrado mediana, donde cada pixel de salida contiene el valor de la mediana en el m-por- n barrio alrededor del píxel correspondiente en la imagen de entrada en.
    
    % Convertir la imagen de escala de grises a una imagen binaria.
    diff_im = im2bw(diff_im,0.12);%im2bw(I, level)convierte la imagen  I  en una imagen binaria. La imagen de salida BW reemplaza todos los píxeles de la imagen 
    %de entrada con la luminancia mayor que en level con el valor de 1 (blanco) y reemplaza a todas las demás pixeles con el valor 0 (negro). Especificar level en el intervalo [0,1]. 
    
    % para determinar el tamanio a reconocer se usa bwareopen para descartar objetos de rojo de menos de 300 pixels
    diff_im = bwareaopen(diff_im,300);
    
    % Etiquetamos los elementos conectados en la imagen
    binaria = bwlabel(diff_im, 8);
    
    % Ahora hacemos el analisis del "objeto" detectado
    % configuramos la region etiquetada
    objetos = regionprops(binaria, 'BoundingBox', 'Centroid');
    
    
%--------------------------------------------------------------------------
%-- 7. Mostramos las imagen y resultados en pantalla ----------------
%--------------------------------------------------------------------------


% mostramos la imagen
    imshow(imagen)
    impixelinfo
    
    hold on%comando para sobre escribir imagenes en pantalla
    
    
    puntosMaxText=text(250,440, strcat('Puntos para ganar =  ', num2str(maxPuntos)));%texto a mostrar en pantalla para los puntos maximos
    set(puntosMaxText, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 16, 'Color', 'y');%se configura el texto anterior
    
    % si el contador llega a 15 es porque ya el recuadro debe cambiar de
    % posicion aleatoria y se tomará como una perdida
    if contador==15
        contador=0;
        perdidas=perdidas+1;
    end%fin if
    
    % si el contador es igual a 0, es porque debe cambiar de posicion
    % aleatoria, ya sea porque llego a 15 o porque el jugador ganó la
    % posicion
    if contador==0
        x=round(7*rand)*numCol; % Genera números enteros aleatorios entre 0 y 7 y lo multiplica por el numero de pixeles de columnas
        y=round(7*rand)*numFil; % Genera números enteros aleatorios entre 0 y 7 y lo multiplica por el numero de pixeles de filas
    end%fin if
    
    contador=contador+1; %aumentamos el contador en 1
    
    %dibujamos el rectánculo en las posiciones aleatorias
    %position X , Y , Ancho, Alto
    rectangle('Position',[x,y,numCol,numFil],...
        'Curvature',[0,0],...
        'EdgeColor', 'g',...
        'LineWidth', 1,...
        'FaceColor', 'g',...
        'LineStyle','-')
    
    
    
    %este es un bucle para encerrar el objeto rojo en un rectangulo y una cruz en el
    for object = 1:length(objetos)
        bb = objetos(object).BoundingBox;%rectángulo alrededor del objeto
        bc = objetos(object).Centroid;%coordenadas del centro del objeto
        rectangle('Position',bb,'EdgeColor','r','LineWidth',3)
        plot(bc(1),bc(2), '-m+')
        
        
        
        xCent=(round(bc(1)));%coordenada en x centroide del objeto
        yCent=(round(bc(2)));%coordenada en y centroide del objeto
        
        
        %si la coordenada x & y está dentro del rectángulo entonces se toma
        %como ganada y se hace el contador a 0 para que aparezca un nuevo
        %rectángulo en una posicion aleatoria y aumentamos las ganadas en 1
        if xCent>x && xCent<x+numCol && yCent>y && yCent<y+numFil
            contador=0;
            ganadas=ganadas+1;
        end%fin if
    end%fin for
    
    %se colocan los textos de puntos de perdidas y ganadas con su
    %respectiva configuracion
    perText=text(40,40, strcat('Perdidas = ', num2str(perdidas)));
    set(perText, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 26, 'Color', 'yellow');
    ganText=text(410,40, strcat('Ganadas = ', num2str(ganadas)));
    set(ganText, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 26, 'Color', 'yellow');
    
    hold off% se cierra la superposición en la imagen de pantalla
end%fin de while



%--------------------------------------------------------------------------
%-- 8. Decision de ganador o perdedor ----------------
%--------------------------------------------------------------------------



%se define si se ganó o se perdió
if perdidas>ganadas
    resultadoText=text(200,240, strcat('PERDISTE '));
    set(resultadoText, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 50, 'Color', 'yellow');
    
else
    resultadoText=text(200,240, strcat('GANASTE'));
    set(resultadoText, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 50, 'Color', 'yellow');
end%fin if y else



%--------------------------------------------------------------------------
%-- 9. Finalización del juego ----------------
%--------------------------------------------------------------------------


% detenemos la captura
stop(vid);


%FLUSHDATA remueve la imagen del motor de adquisicion y la almacena en el buffer
flushdata(vid);

% borramos todo(como en cualquier programa)
clear all

%--------------------------------------------------------------------------
%---------------------------  FIN DEL PROGRAMA ----------------------------
%--------------------------------------------------------------------------