## General suggestions
- It is a bit weird to have to keep changing directories to run the different parts of the pipeline
- Note in comments the Figures/stats the analysis code is generating
- Note in modelling code, what it corresponds to (i.e., what section) in the paper
- Look through the matlab warnings (most of them are harmless, but also easy to solve)
- Sometimes you put different assignment statements on the same line, sometimes on different line. It might be clearer to choose a style and stick to it

## Comments by file

### `/`

- `paper_graphs_and_stats.m`
  - I don't think the `Figure N` comments in this file are accurate anymore...
  - Line 23: it might be worth describing a little what `data` contains. It doesn't have to list all the fields, or anything, but it would be nice to know what the data looks like without having to read `load_cost_data.m`
  - Line 24, either give `n` a more descriptive name, or put a comment to let people know what it is, since it is used a bunch later in the code
  - Lines 85 - 96, 105 - 110, and 119 - 124: I think all of these could be done with loops. Indeed, I think that all could be done using the same loops. That might make it less clear, though
  - Lines 183 - 185: Are the values calculated here just for printing out? Is it worth printing them in a formatted way?
  - Lines 297 and 317: what is `stats` for? Do you use it anywhere? Do you need it?
  - Line 356, `best_model` seems to be used a lot, sometimes quite a lot later. Maybe highlight with comments that it is kind of a big deal
  - Lines 406 - 410: The commented out stuff looks like old code. Can it be removed?
  - Line 421: What is `calcflag` for? Maybe comment?
  - Lines 481 and 485 vs. line 489: Why do the first 2 use `find` and the third one not?
  - Lines 635 and 673: what is `stats` for? Do you use it anywhere? Do you need it?
  - Lines 677 - 682: If you are calculating these to print out, maybe they can be formatted nicely
  - Lines 686 and 703: `stats`, `r`, and `p` seem to be unused as far as I can tell

- `run_supplementary_analyses.m`
  - If these are generating figures for the paper, maybe indicate which code is for which figure
  - Note: I did my best with this file, but it was very hard going. I apologise if I missed something obvious!
  - Lines 30 - 33, 94 - 97: are these doing anything?
  - Lines 109 - 115: If this is old code, maybe it could be removed. If it is interesting for some reason, maybe explain why.
  - Lines 150 - 155: If you are calculating these to print out, maybe they can be formatted nicely
  - Line 360: what is `ignore_flag` for?
  - Line 458: you aren't printing `r` and `p` any more, do you need to calculate them?
  - Lines 603 - 608: Can this be removed?
  - Line 632, 654 - 656, 683 - 685: You don't seem to be doing anything with these
  - Lines 766 - 776: If this is old, can it be removed?
  - Line 778:  You don't seem to be doing anything with these
  - Lines 955+: You are not printing these out anymore. Remove?
  - Lines 1007, 1008, 1037, 1055, 1064 - 1066: You don't seem to be doing anything with these
  - Line 1111: `split` is redundant

- `README.md`
  - I made some changes to the README file to make it more readable
  - Maybe make a single matlab script that runs the entire pipeline?
  - `run_simple_sim.m` doesn't seem to exist anymore
  - `HBI_coc.m` has been renamed
  - There is no `obsolete`
  - Am I right in believing that `run_supplementary_analyses.m` can't run by itself? If so, that should be noted somewhere

### `/modeling/HBI`

- `modeling/HBI/run_model_fitting.m`
  - Lines 47 - 50 are a bit weird. Can it be written something like the following, with comments on the lines that list the parameters:
```matlab
moreDescriptiveName = {'mainc','lurec','missc','fac','respc','initi'};
anotherDescriptiveName = {'mainc','lurec','missc','fac','respc','deltai','initi'};

modelstofit = [get_all_param_combos(moreDescriptiveName) get_all_param_combos(anotherDescriptiveName)];
```
  - Lines 83 - 92: Here you are doing something that is obviously useful for you running the code, but less obviously useful for someone trying to replicate your results. It might be worth mentioning somewhere in the comments that that machinery is just for bootstrapping model creation
  - Lines 110 - 117, `fnames`, `priors`, and `model_labels` could be commented to explain what they are
  - Line 132: maybe expand the comment to give a few details about what is in the struct `cbm`
  - Lines 152 - 169, `param_names`, `transform`, and `costs` could be defined and commented
  - Lines 207+, you are generating a figure, but you don't say what the figure is, or why you are generating it...

- `modeling/HBI/run_model_fitting.m`
  - Line 58: I am not sure what this line is for. Comment?
  - Line 64, what is `modelstofit` for?
  - Lines 112 - 118, `fnames`, `priors`, and `model_labels` could be commented to explain what they are
  - Line 124: what are you calling `cbm_lap` for? What do you get as a result? Comments?
  - Line 133+, You are generating a figure here, and it is probably worth commenting what the figure should be, and what it is for
  - Line 153, it is probably worth elaborating on what the conditional here means
  - Line 160 - 162: you are running `cbm_hbi`, but not really explaining why
  - Line 169+, You are generating a figure here, and it is probably worth commenting what the figure should be, and what it is for
  - Line 200+, This last cell might be better commented. If nothing else, it is probably worth expanding the leading comment to explain what the rest of the code is doing

- `modeling/HBI/HPC_runModelSearch_withNull.m` and `modeling/HBI/sbatch_coce.sh`
  - I assume this is specific to NYU, so it might not need to be in the published version of the code. If you think it would be useful to others though, you can, of course explain why and leave it in there as an example

### `/modeling/`

- `modeling/analyze_cost_component.m`
  - Lines 48+
    - `nmisses`, `nmissesall`, and `misseffect` could be pre declared and commented
    - You are generating a figure with a few subplots. It is probably worth saying in comments what the figure is, and why you are generating it
  - Lines 94+, `proportions` could be pre declared and commented
  - Lines 132+, You are generating more subplots. It is probably worth saying in comments what you are generating and why

- `modeling/coc_createModels.m`
  - `modelStruct` (line 8) looks like it should be used, but it's not. I guess `model` is the variable that you are actually using

- `modeling/getprobs_costlearning.m`
  - This is all really clear! :-)

- `modeling/run_process_model.m`:
  - Generally really clear
  - Mention in README why it outputs a single chart?
  - Explain what `completed` and `components` are in comments when they are initialised (before the loop starting at line 176)
  - Line 223-227 are doing something a bit weird with `maintained`. I would either comment out or delete the code that you are not using here. Or, I guess, you can try to explain what is happening more clearly

- `modeling/simulate_cost_model.m`
  - Lines 126, 127: Are the two commented line alternatives to line 128? If so, do they need to be there (with a comment to explain why), or can they be removed?

