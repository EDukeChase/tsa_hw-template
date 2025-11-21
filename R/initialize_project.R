# --- Initialize New Project from Template ---
library(styler)
library(shrtcts)

#'
#' @description
#' Automates project setup: renames files, sets up shortcuts/dependencies,
#' cleans READMEs, and deletes itself upon completion.
#'
#' @details
#' Actions:
#'   1. Detects the new project's directory name.
#'   2. Renames the generic `.Rproj` and `.qmd` files.
#'   3. Replaces the main `README.md` with the project-specific template.
#'   4. Deletes the now-unneeded project README template.
#'
#' @return This function is called for its side effects and does not return a value.
#'
initialize_project <- function() {
  
  project_dir <- here::here()
  new_name    <- basename(project_dir)
  
  message("Initializing project: '", new_name, "'")
  
  # -- Rename the .Rproj file ---
  old_rproj <- list.files(path = project_dir, pattern = "\\.Rproj$", full.names = TRUE)
  
  if (length(old_rproj) == 1) {
    new_rproj_path <- here::here(paste0(new_name, ".Rproj"))
    file.rename(from = old_rproj, to = new_rproj_path)
    message("Renamed '", basename(old_rproj), "' to '", basename(new_rproj_path), "'")
  } else {
    warning("Found ", length(old_rproj), " .Rproj files. Expected 1. Skipping rename.")
  }
  
  # --- Rename the starter .qmd file ---
  old_qmd <- list.files(path = project_dir, pattern = "\\.qmd$", full.names = TRUE)
  
  if (length(old_qmd) == 1) {
    new_qmd_path <- here::here(paste0(new_name, ".qmd"))
    file.rename(from = old_qmd, to = new_qmd_path)
    message("Renamed '", basename(old_qmd), "' to '", basename(new_qmd_path), "'")
  } else {
    warning("Found ", length(old_qmd), " .qmd files. Expected 1. Skipping rename.")
  }
  
  # --- Setup shortcuts and dependencies ---
  shrtcts_path <- here::here(".shrtcts.R")
  
  if (!file.exists(shrtcts_path)) {
    file_content <- c(
      "# --- RStudio Shortcuts & Dev Dependencies ---",
      "# Set custom keyboard shortcuts and keep dev packages tracked by renv.",
      "",
      "library(styler)     # Code formatting",
      "library(shrtcts)    # Keybinding management",
      "",
      "#' Style Selection",
      "#' @shortcut Ctrl+Alt+A",
      "function() {",
      "  styler::style_selection()",
      "}"
    )
    writeLines(file_content, shrtcts_path)
    message("Created '.shrtcts.R' with 'styler' dependency'")
  }
  
  # Install the shortcuts into RStudio
  if (requireNamespace("shrtcts", quietly = TRUE)) {
    shrtcts::add_rstudio_shortcuts(shrtcts_path)
    message("Keyboard shortcuts installed (Ctrl+Alt+A)")
  }
  
  
  # --- Customize and rerwrite the main README.md ---
  project_readme_template <- here::here("_PROJECT_README.md")
  main_readme_path <- here::here("README.md")
  
  if (file.exists(project_readme_template)) {
    
    # Read template contents
    readme_lines <- readLines(project_readme_template)
    
    # Parse folder name
    # Expected format: yyyy-mm-dd_tsa_homework-##
    pattern <- "^(\\d{4}-\\d{2}-\\d{2})_.*homework-(\\d+)$"
    
    if(grepl(pattern,new_name)) {
      extracted_date <- sub(pattern, "\\1", new_name)
      extracted_num  <- sub(pattern, "\\2", new_name)
      
      message("Detected due date: ", extracted_date)
      message("Detected homework #: ", extracted_num)
      
      # Replace placeholders in text
      readme_lines <- gsub("2025-mm-dd", extracted_date, readme_lines)
      readme_lines <- gsub("\\{num\\}", extracted_num, readme_lines)
    } else {
      warning("Folder name '", new_name, "' does not match 'YYYY-MM-DD_..._homework-##'. Skipping text.")
    }
    
    # Write the modified content to the main README
    writeLines(readme_lines, main_readme_path)
    message("Replaced README.md with project-specific version.")
    
    # Remove the template file
    file.remove(project_readme_template)
    message("Removed temporary file: '_PROJECT_README.md'")
  } else {
    warning("'_PROJECT_README.md' not found. Skipping README update.")
  }
  
  # --- Self-destruct
  # Remove the script itself to clean up the project
  current_script <- here::here("R", "initialize_project.R")
  if(file.exists(current_script)) {
    file.remove(current_script)
    message("Deleted 'R/initialize_project.R'.")
  }
  
  # --- Final instruction ---
  message("\nIMPORTANT: Project initialization complete. Please close and reopen this project.")
  message("Use 'File > Open Project...' and select the new '", new_name, ".Rproj' file.")
  
}

# Automatically run the function when the script is sourced
initialize_project()