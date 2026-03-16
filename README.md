# Location-Intelligence---Gestion-de-crisis-DANA-
# DANA Valencia - Spatial Risk Analytics & Geo-Intelligence Dashboard

![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)
![Shiny](https://img.shields.io/badge/Shiny-0048C0?style=for-the-badge&logo=r&logoColor=white)
![QGIS](https://img.shields.io/badge/QGIS-589632?style=for-the-badge&logo=qgis&logoColor=white)
![Leaflet](https://img.shields.io/badge/Leaflet-199900?style=for-the-badge&logo=leaflet&logoColor=white)
![Plotly](https://img.shields.io/badge/Plotly-3F4F75?style=for-the-badge&logo=plotly&logoColor=white)

> **DANA Valencia** es una aplicación analítica integral (Shiny Dashboard) diseñada para visualizar, interactuar y cuantificar el riesgo hidrológico en la Comunidad Valenciana. Evalúa el impacto demográfico y económico basándose en modelos de Periodos de Retorno (T10, T500) e identifica anomalías estructurales que amplifican el riesgo territorial.

---

## El Reto Analítico y de Negocio
Durante la gestión de emergencias y la planificación urbanística, la administración pública consume informes estáticos (PDFs) que no permiten cruzar variables en tiempo real. 

El verdadero reto no es solo mapear el agua, sino cruzar esa huella hídrica contra el tejido urbano para responder a preguntas críticas: *¿Cuál es el impacto económico neto a 10 años (T10)? ¿Qué municipios sufrirán mayor afección poblacional en un evento extremo (T500)? ¿Qué infraestructuras específicas están agravando el desastre?*

## La Solución
Un pipeline de datos espaciales (Spatial ETL) que ingesta capas vectoriales complejas, reduce su dimensionalidad y las expone a través de una arquitectura web reactiva. Esto permite a los tomadores de decisiones filtrar, segmentar y analizar el riesgo económico y demográfico mediante paneles dinámicos y visualizaciones interactivas.

---

## Arquitectura Técnica y Geoprocesamiento

### Fase 1: Optimización Topológica (QGIS)
- **Simplificación Vectorial:** Procesamiento offline de shapefiles para reducir drásticamente la cantidad de vértices (`_simplificado.shp`), minimizando los *payloads* del servidor y garantizando una latencia baja en la aplicación web.

### Fase 2: Spatial Computing (R & sf)
- **Operaciones Topológicas en Memoria:** Construcción de buffers interactivos de 500m en márgenes fluviales y ejecución de *Spatial Joins* contra polígonos urbanos para acotar el riesgo neto.
- **Estandarización de CRS al vuelo:** Reproyección algorítmica desde sistemas de coordenadas locales hacia Web Mercator (EPSG:4326) para su correcta ingesta en Leaflet.

### Fase 3: Dashboard Reactivo y UI/UX (Shiny, Leaflet & Plotly)
- **Renderizado Condicional:** Paneles de usuario (UI) que ajustan dinámicamente las leyendas y métricas HTML basándose en el contexto espacial seleccionado por el usuario.
- **ColorRamps Dinámicos:** Mapeo numérico en tiempo real donde la intensidad visual responde directamente a las variables cuantitativas de DAÑO ECONÓMICO o AFECCIÓN POBLACIONAL.

---

## Key Findings e Impactos del Análisis

* **Ranking de Vulnerabilidad Municipal:** Identificación y ordenación interactiva (vía Plotly) del Top 10 de municipios con mayor impacto poblacional directo, permitiendo una asignación de recursos basada en datos.
* **Diagnóstico Crítico de Infraestructuras:** Segregación en tiempo real de los "cuellos de botella" hidrológicos (muros, escolleras, entubados) que actúan como amplificadores latentes del desastre, facilitando la priorización de derribos o inversiones de mantenimiento.
* **Transición Digital:** Evolución de la estadística estática y reportes en papel hacia un *Single Source of Truth* (SSOT) reactivo e interactivo.

## Stack Tecnológico
* **Data Wrangling Espacial:** Librería `sf` (Simple Features) y `dplyr`.
* **Desarrollo Web & UI:** R, Shiny (`shinydashboard`).
* **Visualización Interactiva:** Leaflet (Web Maps) y Plotly (Gráficos analíticos dinámicos).
* **Preprocesamiento GIS:** QGIS.

---

##  Cómo ejecutar el Dashboard en local

Para replicar el entorno de análisis y levantar la aplicación web localmente:

1. Clona el repositorio:
```bash
git clone [https://github.com/tu-usuario/dana-valencia-dashboard.git](https://github.com/tu-usuario/dana-valencia-dashboard.git)
cd dana-valencia-dashboard
install.packages(c("shiny", "shinydashboard", "leaflet", "sf", "dplyr", "plotly"))
shiny::runApp("app.R")
```
