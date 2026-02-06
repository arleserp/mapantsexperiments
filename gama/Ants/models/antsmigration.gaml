/**
* Name: antsmigration
* Based on the internal empty template. 
* Author: 57313
* Tags: 
*/


model antsmigration

/* Insert your model definition here */

global {
    /** PARÁMETROS **/
    int population <- 1;
    float diffusion_rate <- 0.7; 
    float evaporation_rate <- 0.02; 
    float food_emission_rate <- 10.0; 
    
    geometry shape <- square(100);

    init {
        create nest_point number: 1 { location <- {15.0, 15.0}; }
        create foodys number: 1 { location <- {85.0, 85.0}; }
        create ant number: population { location <- {15.0, 15.0}; }
    }

    reflex evolve_environment {
        ask foodys {
            ant_grid current_patch <- ant_grid(location);
            if (current_patch != nil) {
                current_patch.chemical <- current_patch.chemical + food_emission_rate;
            }
        }
        ask ant_grid { chemical <- chemical * (1 - evaporation_rate); }
        diffuse var: chemical on: ant_grid proportion: diffusion_rate;
    }
}

/** ENTORNO **/
grid ant_grid width: 100 height: 100 parallel: false {
    float chemical <- 0.0;
    float nest_scent <- 0.0;
    bool is_nest <- false;
    
    init {
        nest_scent <- 200 - (location distance_to {15.0, 15.0});
        if (location distance_to {15.0, 15.0} < 5.0) { is_nest <- true; }
    }

    // Gradiente visual: usamos una condición simple para el color
    rgb color <- #white update: (chemical > 0.01) ? blend(#white, #blue, min(1.0, chemical / 10.0)) : #white;
}

/** ESPECIES **/
species nest_point {
    aspect circle { 
        draw circle(3.0) color: #black; 
    }
}

species foodys {
    aspect default { 
        // Cambiado de 'star' a 'circle' para evitar el error de Unknown Operator
        draw circle(4.0) color: #green; 
        draw circle(6.0) color: rgb(0, 255, 0, 40); 
    }
}

species ant skills: [moving] parallel: false {
    bool carrying_food <- false;

    reflex behavior {
        ant_grid current_patch <- ant_grid(location);
        
        if (!carrying_food) {
            // Seguir gradiente
            ant_grid best_patch <- (current_patch.neighbors) with_max_of (each.chemical);
            if (best_patch != nil and best_patch.chemical > 0.001) {
                heading <- self towards best_patch;
            }
            // Detectar comida
            if (self distance_to (first(foodys)) < 3.0) {
                carrying_food <- true;
                heading <- heading + 180;
            }
        } else {
            // Volver al nido
            ant_grid best_patch <- (current_patch.neighbors) with_max_of (each.nest_scent);
            if (best_patch != nil) { heading <- self towards best_patch; }
            if (current_patch.is_nest) {
                carrying_food <- false;
                heading <- heading + 180;
            }
        }
        heading <- heading + (rnd(10) - 5);
        do move speed: 1.2;
    }

    aspect default {
        // 'draw' ahora recibe una geometría explícita (triangle)
        draw triangle(2.0) color: carrying_food ? #orange : #red rotate: heading + 90;
    }
}

/** EXPERIMENTO **/
experiment MiExperimentoHormigas type: gui {
    output {
        display MapaPrincipal type: 2d {
            grid ant_grid border: #lightgray;
            species foodys;
            species nest_point;
            species ant;
        }
    }
}