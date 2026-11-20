import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

// Tips curados globales (equivalen a lib/core/mocks/tips_mock_data.dart).
const tips = [
  {
    category: "Salud",
    title: "¿Cuándo esterilizar?",
    body: "Consulta con tu veterinario; suele recomendarse entre los 6 y 12 meses según raza y tamaño.",
  },
  {
    category: "Alimentación",
    title: "Ración según peso",
    body: "Ajusta la cantidad diaria al peso y nivel de actividad. Divide en 2 tomas.",
  },
  {
    category: "Paseos",
    title: "Hidratación",
    body: "Lleva agua en paseos largos, sobre todo en días calurosos.",
  },
  {
    category: "Cuidado",
    title: "Refuerzos de vacunas",
    body: "Mantén al día el calendario de vacunas para evitar enfermedades comunes.",
  },
];

async function main() {
  for (const tip of tips) {
    const exists = await prisma.tip.findFirst({ where: { title: tip.title } });
    if (!exists) await prisma.tip.create({ data: tip });
  }
  console.log(`✅ Seed completo (${tips.length} tips).`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
