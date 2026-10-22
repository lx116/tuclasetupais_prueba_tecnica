# tuclasetupais_prueba_tecnica

Prueba tecnica para Tu clase Tu Pais. Realizada el 22 de octubre del 2026

## Getting Started

## Objetivo: 

Desarrollar una aplicación web en Flutter que permita consultar y gestionar visualmente un directorio de contactos empresariales a partir de un conjunto de datos local. La aplicación debe ofrecer carga asíncrona de información, búsqueda en tiempo real, filtrado por departamento, visualización detallada de contactos y gestión de favoritos. Además, debe proporcionar una experiencia adaptable a dispositivos móviles y pantallas de escritorio, garantizando una separación clara entre la interfaz de usuario, la lógica de negocio y el acceso a los datos.

## Contexto: 

La arquitectura del proyecto fue diseñada bajo el enfoque Feature First, utilizando BLoC para la gestión de estados y la separación de responsabilidades. Esta estructura permite organizar el código por funcionalidades independientes, facilitando su mantenimiento, escalabilidad y comprensión.

Para el acceso a los datos, se planteó un servicio de inicialización encargado de verificar la existencia del archivo JSON, validar su estructura y cargar los contactos en memoria, dejándolos disponibles mediante un DataSource. La gestión asíncrona contempla estados de carga, éxito, error y ausencia de resultados, con el propósito de ofrecer una respuesta controlada ante diferentes escenarios.

La navegación se estructuró mediante go_router, utilizando rutas dinámicas (/contacts/:id) para acceder directamente al detalle de cada contacto y permitir compartir su URL. Asimismo, se contempló el uso de query parameters para conservar y compartir los criterios de búsqueda y filtrado por departamento.

## Arquitectura:

La arquitectura del proyecto fue trabajada medainte Feature First y BloC.

## Diseño:

El diseño de la aplicación se planteó bajo un enfoque responsive, priorizando la funcionalidad, la claridad visual y la adaptación a diferentes tamaños de pantalla.

Se estableció un punto de ruptura de 900 píxeles lógicos para diferenciar la experiencia entre dispositivos móviles y escritorio. En pantallas anchas, la interfaz utiliza una distribución de dos columnas basada en el patrón maestro-detalle, mostrando simultáneamente el listado de contactos y la información del contacto seleccionado. En pantallas inferiores a este umbral, ambas vistas se presentan de forma independiente, permitiendo navegar entre ellas.

Para organizar esta experiencia se contempló el uso de ShellRoute de go_router, manteniendo una estructura de navegación coherente.

La interfaz prioriza la búsqueda en tiempo real, los filtros por departamento y la representación explícita de los diferentes estados de la aplicación mediante indicadores de carga, mensajes de error y estados vacíos.

Finalmente, se decidió priorizar las funcionalidades esenciales de consulta, navegación y visualización de contactos, considerando el sistema de favoritos como una funcionalidad de menor prioridad frente a las restricciones de tiempo establecidas para la prueba técnica.

## IA y como se uso:

La IA en este proyecto fue usada como asistente de codificacion. Dado el tiempo limitado, he decidido usar la IA como herrameinta de codigo, enfocando mis esfuerzo a la planificacion y estructura del proyecto. Las decisiones fueron tomadas por mi, lo que me hace responsable de los errores que se puedan presentar en el proyecto. 

Dentro de mis herramientas, estuve trabajando con Claude y Codex alimentadas por las skills de gentleAI y como patron de desarrollo se uso ODD, garantizando un codigo legible y facil de seguir. 

Como desarrolladores, se nos necesita mas que para labores de codigo, un buen desarrollo debe partir desde sus simientos y la estructura se debe definir con anterioridad a la primera linea de codigo. 

Este proyecto de dos horas y media deja ver la coordiancion entre ambas partes. Permitiendo centrar los esfuerzos en probar la app y una correcta ejecucion del proyecto. 

Tambien destacaria en los usos de la IA, el poder hacer un diseño rapido de la app con Claude desing que aunque sencillo, permite hacerse una idea como escalar visualmente hacia el futuro. Pero asi como una IA no remplaza a un desarrollador en el acto de pensar, tampoco reemplaza a un diseñador. Estos diseños aunque funcionales, tambien deben ser valorados por un profesional. 


# LUIS E VELEZ - 2026