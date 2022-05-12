<%!
    import config.project
    import config.version
    import user.personal
    line = "=" * len(config.project.project_name)
%>${config.project.project_name}
${line}

version: ${config.version.version_str}

description: ${config.project.project_description}

${config.project.project_long_description}

	${user.personal.personal_origin}, ${config.project.project_copyright_years}
