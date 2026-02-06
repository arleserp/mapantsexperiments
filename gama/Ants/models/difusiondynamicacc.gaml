/**
* Name: difusiondynamicacc
* Based on the internal empty template. 
* Author: Arles
* Tags: 
*/


model difusiondynamicacc

/* Insert your model definition here */

global {
    float diffusion_rate <- 0.6 min: 0.0 max: 1.0;
    // Mantenemos evaporación en 0 para un ambiente totalmente encerrado
    float evaporation_rate <- 0.0 min: 0.0 max: 1.0; 
    int grid_size <- 50;
    geometry shape <- square(grid_size);

    init {
        write "Iniciando simulación de ambiente cerrado...";
        // Fuente de olor constante
        ask cells[25, 25] { 
            food <- 5.0; // Reducimos un poco el valor base porque ahora se acumula
        } 
    }

    reflex diffusion_dynamics {
        // CAMBIO 1: EMISIÓN ACUMULATIVA
        ask cells where (each.food > 0) {
            // Usamos += para que el olor se sume en cada ciclo en lugar de resetearse
            chemical <- chemical + food*100; 
        }
        
        // STEP 2: DIFFUSION
        diffuse var: chemical on: cells propagation: diffusion proportion: diffusion_rate;

        // STEP 3: EVAPORATION
        if (evaporation_rate > 0) {
            ask cells {
                chemical <- chemical * (1 - evaporation_rate);
            }
        }
    }
} 

grid cells width: grid_size height: grid_size neighbors: 6 {
    float chemical <- 0.0;
    float food <- 0.0;
    rgb color <- #black update: calculate_color();
    
    rgb calculate_color {
        // CAMBIO 2: ELIMINAR EL CÍRCULO NEGRO (MÁSCARA)
        // Se elimina la condición de "distance_to > 24" para permitir ver todo el ambiente.

        if (grid_x = 17 and grid_y = 17) { return #yellow; }

        if (food > 0) { return #red; } 
        
        if (chemical > 0) { 
            // CAMBIO 3: AJUSTE DE VISUALIZACIÓN
            // Usamos un multiplicador menor para que el degradado se vea mientras se llena el cuarto
            return hsb(0.6, 1.0, min(1.0, chemical / 10.0)); 
        } 
        return #black;
    }
}

experiment MainExperiment type: gui {
    parameter "Diffusion Speed" var: diffusion_rate;
    parameter "Evaporation Speed" var: evaporation_rate;
    output {
        display "Environment" background: rgb(20, 20, 20) {
            grid cells;
        }
        display "Grafica del Centro" {
            chart "Smell at [17,17]" type: series {
                data "Intensidad" value: cells[17,17].chemical color: #yellow;
            }
        }
        monitor "Valor Exacto en [17,17]" value: cells[17,17].chemical;
    }
}