"""
Convertit la feuille "Catalogue Complet (a plat)" du fichier Excel officiel
EduPay_Catalogue_Fournitures_3Kits en un asset JSON exploitable par l'app
Flutter (edupay/assets/data/school_catalogue.json).

Aucune donnee (classe, article, prix) n'est retapee a la main : ce script ne
fait que reformater les lignes du fichier source. A relancer si le fichier
Excel est mis a jour.
"""
import json
import os
import re
import unicodedata

import openpyxl

_HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(
    _HERE, "..", "..", "backendUser", "EduPay_Catalogue_Fournitures_3Kits (2).xlsx"
)
OUT = os.path.join(_HERE, "..", "assets", "data", "school_catalogue.json")

KIT_COLUMNS = {
    "basic": ("Kit Basique (Oui/Non)", 8),
    "comfort": ("Kit Essentiel (Oui/Non)", 9),
    "complete": ("Kit Premium (Oui/Non)", 10),
}


def slugify(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value)
    ascii_only = normalized.encode("ascii", "ignore").decode("ascii")
    slug = re.sub(r"[^a-zA-Z0-9]+", "_", ascii_only).strip("_").lower()
    return slug or "article"


def main() -> None:
    wb = openpyxl.load_workbook(SRC, data_only=True)
    ws = wb["Catalogue Complet (\u00e0 plat)"]
    rows = list(ws.iter_rows(min_row=2, values_only=True))

    classes = []  # ordered, deduped niveau labels
    levels = {}  # niveau -> {cycle, kits: {tier: {price, items: []}}, articles: []}

    for row in rows:
        (
            cycle,
            niveau,
            _type_ens,
            _serie,
            categorie,
            article,
            quantite,
            _unite,
            basique,
            essentiel,
            premium,
            prix_unitaire,
            *_rest,
        ) = row

        if niveau is None or article is None:
            continue

        if niveau not in levels:
            classes.append(niveau)
            levels[niveau] = {
                "cycle": cycle,
                "kits": {"basic": [], "comfort": [], "complete": []},
                "articles": [],
            }

        entry = levels[niveau]
        quantity = int(quantite or 0)
        unit_price = int(prix_unitaire or 0)
        article_id = slugify(f"{categorie}_{article}")
        # Garantit l'unicite de l'id au sein de la classe (au cas ou deux
        # lignes distinctes produiraient le meme slug).
        base_id = article_id
        suffix = 2
        existing_ids = {a["id"] for a in entry["articles"]}
        while article_id in existing_ids:
            article_id = f"{base_id}_{suffix}"
            suffix += 1

        item = {
            "id": article_id,
            "category": categorie,
            "label": article,
            "quantity": quantity,
            "unitPrice": unit_price,
        }
        entry["articles"].append(item)

        flags = {"basic": basique, "comfort": essentiel, "complete": premium}
        for tier, flag in flags.items():
            if flag == "Oui":
                entry["kits"][tier].append(dict(item))

    result_levels = {}
    for niveau, entry in levels.items():
        kits = {}
        for tier, items in entry["kits"].items():
            price = sum(i["quantity"] * i["unitPrice"] for i in items)
            kits[tier] = {"price": price, "items": items}
        result_levels[niveau] = {
            "cycle": entry["cycle"],
            "kits": kits,
            "articles": entry["articles"],
        }

    payload = {
        "source": "EduPay_Catalogue_Fournitures_3Kits.xlsx (feuille 'Catalogue Complet (\u00e0 plat)')",
        "classes": classes,
        "levels": result_levels,
    }

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=1)

    print("classes:", len(classes))
    print("written to", OUT)
    # Petit sanity check.
    sample = result_levels[classes[0]]
    print("sample niveau:", classes[0], "kits:", {k: v["price"] for k, v in sample["kits"].items()})


if __name__ == "__main__":
    main()
