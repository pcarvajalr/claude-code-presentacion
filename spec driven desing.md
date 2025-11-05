
repo: https://github.com/github/spec-kit

What is Spec-Driven Development?
Spec-Driven Development flips the script on traditional software development. For decades, code has been king — specifications were just scaffolding we built and discarded once the "real work" of coding began. Spec-Driven Development changes this: specifications become executable, directly generating working implementations rather

tener instalado uvx
uvx --version
pip install uv

pasos:
1. Configuracion
2. especificaciones, plan, tareas.
3. implementacion

que es un mcp, descripcion de un mcp.

mcps que vamos a usar context7 y figma

instalar mcp context7
claude mcp add context7 -- npx -y @upstash/context7-mcp

instalar mcp figma
claude mcp add --transport http figma https://mcp.figma.com/mcp

logear mcp figma

ubicarnos en directorio de proyectos o repositorios

tener git configurado para crear repo del proyecto

instalacion de spec-kit
uvx --from git+https://github.com/github/spec-kit.git specify init <nombre-proyecto>

crear proyecto laravel (con comando laravel se crea la estructura basica de un proyecto laravel)

comandos de configuracion
/speckit.constitution  especificaciones principales, proyecto laravel integrado con api whatsapp cloud. Diseño existente en figma

/speckit.specify crea una plataforma con login administrado, para gestionar chats de whatsapp, multiusuario y multi linea.  pantallas de configuracion de lineas de whatsapp y plantillas en meta. rol de usuarios. diseño en https://www.figma.com/design/6Ni3yOjH2eHVMSxWs3maMK/%F0%9F%9F%A8-E-MA---Mockups?node-id=0-1&p=f&t=ZH09BKIb6ckFzhEC-0

resolver NEEDS CLARIFICATION

/speckit.plan plataforma laravel de chats de whatsapp, base de datos sql, recibe mensajes del webhook existente a travez de socket. usa context7 para implementar las versiones de cada  tecnologia. usa mcp de figma para diseño existente. Todo desplegado en docker compose. evita sobreingenieria.

/speckit.task

/speckit.implement