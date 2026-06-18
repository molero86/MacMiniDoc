import argparse
import pathlib
import sys
import textwrap

try:
    import yaml
except ImportError as exc:  # pragma: no cover
    raise SystemExit(
        "Falta dependencia PyYAML. Instala con: pip install -r forja-delivery-lite/requirements.txt"
    ) from exc


def write_file(path: pathlib.Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def render_readme(data: dict) -> str:
    project = data["project"]
    modules = data.get("modules", [])
    lines = [
        f"# {project['name']}",
        "",
        project.get("description", "Proyecto generado por Forja Delivery Lite."),
        "",
        "## Modulos",
        "",
    ]
    for module in modules:
        lines.append(f"- {module}")
    lines.extend(
        [
            "",
            "## Estado",
            "",
            "Proyecto inicial generado automaticamente.",
        ]
    )
    return "\n".join(lines) + "\n"


def render_docs_overview(data: dict) -> str:
    project = data["project"]
    stack = data.get("stack", {})
    return textwrap.dedent(
        f"""
        # Vision del Proyecto

        ## Resumen

        - Nombre: {project['name']}
        - Empresa: {project.get('company', 'forja-digital')}
        - Owner: {project.get('owner', 'por-definir')}

        ## Stack propuesto

        - Backend: {stack.get('backend', 'por-definir')}
        - Base de datos: {stack.get('database', 'por-definir')}
        - Web: {stack.get('web', 'por-definir')}
        - App: {stack.get('mobile', 'por-definir')}
        """
    ).strip() + "\n"


def render_gate_file(data: dict) -> str:
    gates = data.get("quality_gates", {})
    return textwrap.dedent(
        f"""
        quality_gates:
          min_test_coverage: {gates.get('min_test_coverage', 70)}
          require_lint: {str(gates.get('require_lint', True)).lower()}
          require_readme: {str(gates.get('require_readme', True)).lower()}
        """
    ).lstrip()


def scaffold(base_dir: pathlib.Path, blueprint: dict) -> pathlib.Path:
    project_name = blueprint["project"]["name"]
    root = base_dir / project_name

    modules = blueprint.get("modules", [])
    for module in modules:
        (root / module).mkdir(parents=True, exist_ok=True)

    write_file(root / "README.md", render_readme(blueprint))
    write_file(root / "docs" / "overview.md", render_docs_overview(blueprint))
    write_file(root / "forja" / "quality-gates.yaml", render_gate_file(blueprint))
    write_file(
        root / ".gitignore",
        """.venv/
__pycache__/
*.pyc
.env
node_modules/
build/
dist/
""",
    )

    return root


def load_blueprint(path: pathlib.Path) -> dict:
    data = yaml.safe_load(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError("El blueprint debe ser un objeto YAML")
    if "project" not in data or "name" not in data["project"]:
        raise ValueError("Falta project.name en el blueprint")
    return data


def main() -> int:
    parser = argparse.ArgumentParser(description="Scaffold de proyecto para Forja Delivery Lite")
    parser.add_argument("--blueprint", required=True, help="Ruta al archivo YAML blueprint")
    parser.add_argument(
        "--output-dir",
        default=".",
        help="Directorio base donde se creara la carpeta del proyecto",
    )
    args = parser.parse_args()

    blueprint_path = pathlib.Path(args.blueprint).resolve()
    output_dir = pathlib.Path(args.output_dir).resolve()

    if not blueprint_path.exists():
        raise SystemExit(f"Blueprint no encontrado: {blueprint_path}")

    try:
        blueprint = load_blueprint(blueprint_path)
        project_root = scaffold(output_dir, blueprint)
    except Exception as exc:  # pragma: no cover
        raise SystemExit(f"Error generando scaffold: {exc}") from exc

    print(f"Proyecto generado en: {project_root}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
