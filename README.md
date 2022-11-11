# Wagers for Work: A novel experimental paradigm for cognitive effort cost decomposition (Master et. al. 2022)

Experimental task, behavioral analysis, and modeling code for the **Costs of Cognitive Effort** project (Master, Curtis, & Dayan) 


## Overview

The majority of this is Matlab analysis and modeling code, written to analyze data collected on Amazon Mechanical Turk. The experimental task is contained within the `/cost` folder, and is implemented in javascript with JsPsych and custom JsPsych plugins.

The modelling and analysis code are run as follows:
```
//PUT DETAILS IN HERE ABOUT HOW TO RUN EACH BIT OF THE PIPELINE
//THESE SHOULD BE IN ORDER, SO THAT COPYING AND PASTING THEM SHOULD WORK
```

## Structure

The project is made up of the following folders:

### `/cost`

This contains the experimental code (including images, custom plugins, and pre-built jspsych functions).

`cost.html` is the main experimental page (initializes all, loads up entire experimental timeline), and `Index.html` is an obsolete example for a main experiment page (the old version of cost.html).

There is also code for collecting Need for Cognition and Perfectionism scores with the Need for Cognition Scale (NFC) and Short Almost Perfect Scale (SAPS).

### `/data_loading_and_scoring`

This contains functions I wrote for loading in my mturk data from `.json` format, or otherwise formatting data. It has code for scoring the NFC and SAPS questionnaires. It also has code for formatting every subject's data into the same format, from the completely unprocessed MTurk files, for ease of comparison on the group level, stats running, etc.

### `/example_data` 

In this folder there are processed data files, including the file `toAnalyze.mat`,
which is a table full of values important for running model fitting within /modeling.
The version provided in the public repository contains example data from one batch
worth of subjects. `toAnalyze.mat` is created within `modeling/run_simple_sims.m`.

### `/modeling`

The outer level of `/modeling` has modeling functions that are generally necessary for running the cost learning/changing models described in the paper. They are used both in the HBI & type II ML model fitting directories, as they are the core of my models. You'll see from looking inside `simulate_cost_model.m` or `getprobs_costlearning.m`, that the scripts are written to be super flexible to the model specified such that they can handle many situations, including different parameter values, different included parameters (alpha vs. delta, for example), different fitting algorithms, different subjects, etc. 

`simulate_cost_model.m` simulates data given specific parameter values/model specifications, while `getprobs_costlearning.m` takes in the model & subject data and returns the probability of that subject's choices given those parameter values & that model. `getprobs_costlearning.m` can provide log likelihoods, negative log likelihoods, and maximum a priori values for each parameter set it's given.

### `/modeling/HBI`

This contains code for running the Hierarchical Bayesian Inference model fitting package by Piray & Daw. Included in this folder is multiple files per model which describe how well the model fits real subject data, as well as simulated subject data. These files are referenced by the outer shell `HBI_coc.m`, which can load any model you specify to display how well it fits with the current model settings.

### `modeling/typeII_ML_fitting` 

This code I wrote for running type II maximum likelihood (expectation maximization (EM) algorithm), incorporating group-level priors into individual level parameter fits. This is not the method we ended up using, so it's not entirely up to date with the final results, but it may be helpful to someone... so I'm including it. I can't promise it's perfect or all that readable.

### `/plotting` 

I have some functions for making nice figures. There are two plugins in there, one called [superbar](https://www.mathworks.com/matlabcentral/fileexchange/57499-superbar), and the other called [violin](https://www.mathworks.com/matlabcentral/fileexchange/45134-violin-plot).

