#Cargamos las librerías necesarias:
library(shiny)
library(shinydashboard)
library(leaflet)
library(sf)
library(dplyr)
library(plotly) 

#Cargamos cada capa de QGis y las transformamos, ya que, las necesitamos en SRC4326 
#para poder trabajar con Shinny:
buffer_rio <- st_read("capas/buffer_500m_simplificado.shp") %>% st_transform(4326)
interseccion_riesgo <- st_read("capas/interseccion_RiesgoPob500_simplificado.shp") %>% st_transform(4326)
pozos <- st_read("capas/pozos_metros_valenciana.shp") %>% st_transform(4326)
embalses <- st_read("capas/embalses_valenciana_simlificado.shp") %>% st_transform(4326)
obj_long <- st_read("capas/objetos_longitudinales_simplificado.shp") %>% st_transform(4326)
obj_trans <- st_read("capas/obstaculos_transversales_valenciana.shp") %>% st_transform(4326)
rios_y_barrancos <- st_read("capas/rios_y_barrancos_valenciana_simplificado.shp") %>% st_transform(4326)
zonas_inundables <- st_read("capas/zonas_inundables_valenciana_b_Simplificado.shp") %>% st_transform(4326)
riesgo_eco <- st_read("capas/Riesgo_ECO_T10_Valenciana_Simplificado.shp") %>% st_transform(4326)
riesgo_pob <- st_read("capas/riesgo_poblacion_T500_valenciana_simplificado.shp") %>% st_transform(4326)

#UI: Definimos la interfaz gráfica del usuario:
ui <- dashboardPage( #Creamos el contenedor principal en estilo dashboard (con barra lateral, cabecera, y cuerpo central).
  dashboardHeader(title = "Zonas Inundables - CV"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Inicio", tabName = "inicio", icon = icon("home")),
      menuItem("Mapa interactivo", tabName = "mapa", icon = icon("map")),
      menuItem("Gráficas", tabName = "graficas", icon = icon("chart-bar")),
      menuItem("Memoria", tabName = "memoria", icon = icon("file-pdf")),
      menuItem("Vídeo", tabName = "video", icon = icon("video"))
    )
  ),
  dashboardBody( #abre por omisión.
    tabItems(
      #INICIO: Definimos el contenido de la pestaña Inicio.
      tabItem(tabName = "inicio",
              tags$div(
                style = "background-color: blue; padding: 20px; border-radius: 10px; text-align: center;",
                
                tags$div(
                  style = "background-color: lightblue; color: blue; padding: 25px; border-radius: 10px; margin-bottom: 20px;",
                  h1(strong("Análisis de zonas inundables")),
                  h3(strong("Comunidad Valenciana"))
                ),
                
                tags$img(src = "imagen_portada.png",
                         style = "width: 100%; max-width: 1000px; height: auto; margin-bottom: 20px;"),
                
                tags$h4(strong(style = "color:white;","Integrantes:")),
                tags$p(style = "color: white;","Marta, Iñaki, Javier, David e Isaac"),
                
                br(),
                tags$p(style = "color: white;","Esta aplicación explora diferentes capas espaciales relacionadas con el riesgo de inundaciones."),
                tags$p(style = "color: white;","Navega usando el menú de la izquierda para acceder al mapa interactivo, gráficas, memoria del proyecto y un vídeo explicativo.")
              )
      ),
      
      
      #MAPA: Definimos el contenido de la pestaña Mapa interactivo.
      tabItem(tabName = "mapa",
              fluidRow( #Organiza el contenido en una fila con dos columnas.
                column(width = 3,
                       box(title = "Capas a mostrar:", status = "primary", solidHeader = TRUE, width = 12,
                           checkboxGroupInput("capas", NULL,
                                              choices = list(
                                                "Buffer ríos" = "buffer",
                                                "Intersección riesgo población" = "interseccion",
                                                "Pozos" = "pozos",
                                                "Embalses" = "embalses",
                                                "Objetos longitudinales" = "long",
                                                "Obstáculos transversales" = "trans",
                                                "Rios y barrancos" = "ryb",
                                                "Zonas inundables" = "zonas_inundables",
                                                "Riesgo económico" = "riesgo_eco",
                                                "Riesgo población" = "riesgo_pob"
                                              ),
                                              selected = character(0)
                           )
                       )
                ),
                column(width = 9,
                       leafletOutput("mapa", height = "80vh") #Mostramos el mapa Leaflet interactivo en tiempo real.
                )
              )
      ),
      
      
      
      #GRÁFICAS: Definimos el contenido de la pestaña de Gráficas.
      tabItem(tabName = "graficas",
              fluidRow(  #Mostramos desplegable para que el usuario elija una de las capas.
                box(width = 12,
                    selectInput("capa_grafica", "Selecciona la gráfica:",
                                choices = c(
                                  "Municipios más afectados",
                                  "Tipología de objetos longitudinales",
                                  "Tipología de obstáculos transversales",
                                  "Estado de los obstáculos transversales",
                                  "Distribución por actividad económica"
                                ))
                )
              ),
              
              #Mostramos tanto la gráfica como la leyenda explicativa conjuntamente para mayor interpretabilidad.
              fluidRow(
                column(width = 8,
                       box(width = 12, plotlyOutput("grafico_dinamico")) #gráfico generado con plotly, que se define en el server.
                ),
                #Leyenda gráfico de objetos longitudinales cuando se renderice.
                column(width = 4,
                       conditionalPanel(
                         condition = "input.capa_grafica == 'Tipología de objetos longitudinales'",
                         box(width = 12, status = "primary", solidHeader = TRUE,
                             title = "Tipos de objetos longitudinales",
                             uiOutput("leyenda_longitudinales")
                         )
                       ),
                       #Leyenda gráfico de obstáculos transversales cuando se renderice.
                       conditionalPanel(
                         condition = "input.capa_grafica == 'Tipología de obstáculos transversales' || input.capa_grafica == 'Estado de los obstáculos transversales'",
                         box(width = 12, status = "primary", solidHeader = TRUE,
                             title = "Tipos de obstáculos transversales",
                             uiOutput("leyenda_transversales")
                         )
                       )
                )
              )
      ),
      
      
      #PDF MEMORIA:
      tabItem(tabName = "memoria",
              tags$iframe(style = "height:80vh; width:100%", src = "memoria.pdf")
      ),
      
      #VÍDEO:
      tabItem(tabName = "video",
              tags$video(src = "video.mp4", type = "video/mp4", controls = NA, width = "100%", height = "500px")
      )
    )
  )
)

#SERVER: Definimos la lógica der servidor en la app.
#Es decir, es momento de: procesar datos, reaccionar a las acciones de usuario y generar elementos dinámicos.
server <- function(input, output, session) {
  
  #Mapa:
  output$mapa <- renderLeaflet({ #Definimos cómo se renderiza (genera) el mapa en la app con Leaflet.
    leaflet(options = leafletOptions(minZoom = 7)) %>% 
      addTiles() %>%
      setView(lng = -0.75, lat = 39.6, zoom = 8) %>% #Centramos el mapa.
      setMaxBounds(lng1 = -1.5, lat1 = 37.8, lng2 = 1.2, lat2 = 41.0) #Establecemos los límites máximos (sólo interesa Comunidad Valenciana).
  })
  
  # Mostramos dinámicamente las capas geográficas en el mapa según las selecciones del usuario.
  observe({ #Según los cambios en la app (como marcar o desmarcar casillas del checkbox de capas), se actualiza el mapa.
    proxy <- leafletProxy("mapa") %>% clearShapes() #Borramos las capas previas, para que no se dupliquen al volver a activarse.
    
    # Destacar que dada bloque if (...) comprueba si el usuario ha activado esa capa en el checkbox. 
    
    # Buffer de ríos:
    if ("buffer" %in% input$capas) {
      proxy <- proxy %>% addPolygons(data = buffer_rio, color = "skyblue", weight = 1, fillOpacity = 0.5,
                                    popup = ~as.character(geonameTxt), label = ~as.character(geonameTxt))}
    
    # Intersección riesgo población:
    if ("interseccion" %in% input$capas) {
      proxy <- proxy %>% addPolygons(data = interseccion_riesgo, color = "red", weight = 1, fillOpacity = 0.5,
                                     popup = ~as.character(NOM_MUNICI), label = ~as.character(NOM_MUNICI))}
    
    # Pozos:
    if ("pozos" %in% input$capas) {
      proxy <- proxy %>% addCircleMarkers(
        data = pozos, radius = 3, color = "orange", fillOpacity = 0.8,
        popup = ~as.character(nombre), label = ~as.character(nombre),
        clusterOptions = markerClusterOptions(),
        group = "pozos")} 
    else {proxy <- proxy %>% clearGroup("pozos")}
    
    
    # Embalses:
    if ("embalses" %in% input$capas) {
      proxy <- proxy %>% addPolygons(
        data = embalses, color = "green", weight = 1, fillOpacity = 0.6,
        popup = ~as.character(NOMBRE), label = ~as.character(NOMBRE))}
    
    # Objetos longitudinales:
    if ("long" %in% input$capas) {
      proxy <- proxy %>% addPolylines(data = obj_long, color = "purple", weight = 2,
                                      popup = ~paste0("<b>Tipo:</b> ", tipo_infr, "<br><b>Tipología:</b> ", tipologia),
                                      label = ~paste(tipo_infr, "-", tipologia))}
    
    # Obstáculos transversales:
    if ("trans" %in% input$capas) {
      proxy <- proxy %>% addCircleMarkers(
        data = obj_trans, radius = 3, color = "black", fillOpacity = 0.8,
        popup = ~as.character(TIPO_INFR), label = ~as.character(TIPO_INFR),
        clusterOptions = markerClusterOptions(),
        group = "trans")} 
    else {proxy <- proxy %>% clearGroup("trans")}
    
    # Ríos y barrancos:
    if ("ryb" %in% input$capas) {
      proxy <- proxy %>% addPolygons(data = rios_y_barrancos, color = "blue", weight = 1, fillOpacity = 1,
                                     popup = ~as.character(geonameTxt), label = ~as.character(geonameTxt))}
    if ("zonas_inundables" %in% input$capas) {
      proxy <- proxy %>%
        addPolygons(
          data = zonas_inundables,
          fillColor = "grey",         
          color = "black",            
          weight = 1,
          fillOpacity = 0.5,          
          popup = ~as.character(RIO),
          label = ~as.character(RIO)
        )
    }
    
    if ("riesgo_eco" %in% input$capas) {
      pal_eco <- colorNumeric(
        palette = colorRampPalette(c("white", "darkgreen"))(100), 
        domain = riesgo_eco$DAÑ_EC_ES,
        na.color = "transparent"
      )
      
      proxy <- proxy %>%
        addPolygons(
          data = riesgo_eco,
          fillColor = ~pal_eco(DAÑ_EC_ES),
          color = "black",
          weight = 1,
          fillOpacity = 0.7,
          popup = ~as.character(DAÑ_EC_ES),
          label = ~as.character(DAÑ_EC_ES)
        )
    }
    
    
    if ("riesgo_pob" %in% input$capas) {
      pal_riesgo <- colorNumeric(
        palette = colorRampPalette(c("white", "red"))(100),  
        domain = riesgo_pob$NUM_AFE_ZI,
        na.color = "transparent"
      )
      
      proxy <- proxy %>%
        addPolygons(
          data = riesgo_pob,
          fillColor = ~pal_riesgo(NUM_AFE_ZI),
          color = "black",
          weight = 1,
          fillOpacity = 0.7,
          popup = ~as.character(NUM_AFE_ZI),
          label = ~as.character(NUM_AFE_ZI)
        )
    }
    
    
  })
  
  #GRÁFICAS:
  output$grafico_dinamico <- renderPlotly({
    capa <- input$capa_grafica
    
    if (capa == "Municipios más afectados") {
      datos <- interseccion_riesgo %>%
        st_drop_geometry() %>%
        count(NOM_MUNICI) %>%
        filter(!is.na(NOM_MUNICI)) %>%
        slice_max(n, n = 10)
      
      plot_ly(datos,
              x = ~n,
              y = ~reorder(NOM_MUNICI, n),
              type = "bar",
              orientation = 'h',
              text = ~n,
              textposition = 'auto',
              marker = list(color = "red"),
              showlegend = FALSE) %>%
        layout(
          title = "Municipios más afectados (intersección riesgo población)",
          xaxis = list(title = "Cantidad de intersecciones"),
          yaxis = list(title = "Municipio"),
          margin = list(l = 1))
      
    } else if (capa == "Tipología de objetos longitudinales") {
      datos <- obj_long %>%
        st_drop_geometry() %>%
        mutate(tipo_infr= as.character(tipo_infr)) %>%  
        count(tipo_infr) %>%
        filter(!is.na(tipo_infr)) %>%
        arrange(n)
      
      plot_ly(datos,
              x = ~n,
              y = ~reorder(tipo_infr, n),
              type = "bar",
              orientation = 'h', 
              marker = list(color = "blue"),
              showlegend = FALSE) %>%
        layout(
          title = "Tipos de objetos longitudinales",
          xaxis = list(title = "Cantidad"),
          yaxis = list(title = "Tipo de infraestructura"),
          margin = list(l = 150))
      
      
    } else if (capa == "Tipología de obstáculos transversales") {
      datos <- obj_trans %>%
        st_drop_geometry() %>%
        count(TIPO_INFR) %>%
        filter(!is.na(TIPO_INFR)) %>%
        arrange(desc(n))
      
      plot_ly(datos,
              x = ~n,  
              y = ~reorder(TIPO_INFR, n),  
              type = "bar",
              text = ~n,
              textposition = 'auto',
              marker = list(color = "purple"),
              showlegend = FALSE,
              orientation = 'h'  ) %>%
        layout(
          title = "Tipos de obstáculos transversales",
          xaxis = list(title = "Cantidad"),
          yaxis = list(title = "Tipo de obstáculo"),
          margin = list(l = 150)  )
      
      
    } else if (capa == "Estado de los obstáculos transversales") {
      datos <- obj_trans %>%
        st_drop_geometry() %>%
        count(TIPO_INFR, ESTADO) %>%
        filter(!is.na(TIPO_INFR) & !is.na(ESTADO))
      
      plot_ly(datos,
              y = ~TIPO_INFR,   
              x = ~n,           
              color = ~ESTADO,
              type = "bar",
              orientation = 'h',  
              text = ~n,
              textposition = 'none',  
              showlegend = TRUE) %>%
        layout(
          barmode = "stack",
          title = "Estado de los obstáculos transversales",
          xaxis = list(title = "Cantidad"),
          yaxis = list(title = "Tipo de obstáculo transversal"),
          margin = list(l = 150))
      
    } else if (capa == "Distribución por actividad económica") {
      datos <- riesgo_eco %>%
        st_drop_geometry() %>%
        count(TIP_ACT_EC) %>%
        filter(!is.na(TIP_ACT_EC)) %>%
        arrange(n)
      
      plot_ly(datos,
              x = ~n,
              y = ~reorder(TIP_ACT_EC, n),
              type = "bar",
              orientation = "h",
              marker = list(color = "darkgreen"),
              text = ~n,
              textposition = "auto") %>%
        layout(
          title = "Distribución por tipo de actividad económica",
          xaxis = list(title = "Cantidad"),
          yaxis = list(title = "Tipo de actividad económica"),
          margin = list(l = 200))
    }
  })
  
  
  #LEYENDA PARA OBJETOS LONGITUDINALES:
  output$leyenda_longitudinales <- renderUI({
    HTML("<ul>
      <li><b>Muro:</b> Muros verticales de contención para defensa frente a inundaciones.</li>
      <li><b>Mota:</b> Elevaciones artificiales de tierra que actúan como diques para defensa frente a inundaciones.</li>
      <li><b>Escollera:</b> Roca suelta o bloques para proteger márgenes del cauce.</li>
      <li><b>Gavión:</b> Cajas metálicas rellenas de piedra para reforzar márgenes.</li>
      <li><b>Relleno:</b> Material añadido para elevar o reforzar márgenes del cauce, facilitando la contención del agua o la estabilización del terreno.</li>
    </ul>")})
  
  #LEYENDA PARA OBSTÁCULOS TRANSVERSALES:
  output$leyenda_transversales <- renderUI({
    HTML("<ul>
    <li><b>Salto vertical:</b> Desnivel abrupto en el cauce que provoca una caída de agua, generando un salto o cascada.</li>
    <li><b>Paso sobre paramento:</b> Infraestructura que permite cruzar sobre una estructura construida en el cauce.</li>
    <li><b>Paso entubado:</b> Conducto cerrado que permite el paso del agua por debajo de infraestructuras como carreteras.</li>
    <li><b>Obstáculo mixto:</b>  Infraestructura que combina varios tipos de estructuras (muros, saltos, entubados) para el control o paso de agua en cauces.</li>
  </ul>")})
  
}


# Ejecutamos app:
shinyApp(ui, server)