name: Create Release

on:
  push:
    tags:
      - "v*.*.*"
  workflow_dispatch:
    inputs:
      tag:
        description: 'The version for this release. eg: v1.5.2'
        required: true
        type: string

permissions:
  contents: write
 
## DONT REMOVE
## INSPIRATION: https://github.com/addmix/godot_aerodynamic_physics/blob/7adf96eb7daada41626f0cb82a9a8c3eb9f96fc2/.github/workflows/create_release.yml
jobs:
  release:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v5
        with:
          ref: main

      - name: Prepare Asset Package
        run: |
          [ -d .git ] && rm -r .git/
          [ -d docs ] && rm -r docs
          [ -f README.md ] && rm README.md
          find . -name "*.blend" -type f -delete
          find . -name "*.blend.import" -type f -delete

          

          mkdir -p ../${{ github.event.repository.name }}_temp/addons/${{ github.event.repository.name }}
          mv {.,}* ../${{ github.event.repository.name }}_temp/addons/${{ github.event.repository.name }}
          
          echo -e "${{ github.event.repository.html_url }}" > ../${{ github.event.repository.name }}_temp/addons/${{ github.event.repository.name }}/git_source.md
          echo -e "[InternetShortcut]\nURL=${{ github.event.repository.html_url }}" > ../${{ github.event.repository.name }}_temp/addons/${{ github.event.repository.name }}/git_source.url
          echo -e "[InternetShortcut]\nURL=https://github.com/${{ github.repository_owner }}/${{ github.event.repository.name }}/releases/latest/download/${{ github.event.repository.name }}.zip\n" > ../${{ github.event.repository.name }}_temp/addons/${{ github.event.repository.name }}/download_latest.url

          mv ../${{ github.event.repository.name }}_temp/addons ../${{ github.event.repository.name }}

          
          cd ..


          git clone  --recursive https://github.com/EloiStree/godot_empty_project_for_addons_using_godot_xr_tool.git godot_empty_project_temp
          [ -f godot_empty_project_temp/README.md ] && rm godot_empty_project_temp/README.md          
          [ -d godot_empty_project_temp/.git ] && rm -rf godot_empty_project_temp/.git
          [ -d godot_empty_project_temp/.github ] && rm -rf godot_empty_project_temp/.github
          
          
          cp -r godot_empty_project_temp/. ${{ github.event.repository.name }}/
          rm -rf godot_empty_project_temp

          find "${{ github.event.repository.name }}/" -type d -name ".github" -exec rm -rf {} +
         
          cd ${{ github.event.repository.name }}/

          zip -r ../${{ github.event.repository.name }}.zip ./*
    
      - name: Create Release
        uses: softprops/action-gh-release@v2
        with:
          files: ../${{ github.event.repository.name }}.zip
          generate_release_notes: true
          tag_name: ${{ inputs.tag }}
          draft: false



          
