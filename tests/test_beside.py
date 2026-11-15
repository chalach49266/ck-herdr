"""Unit test for ck-herdr's beside layout (no hc, no app)."""
import importlib.machinery, importlib.util, pathlib

path = pathlib.Path(__file__).resolve().parents[1] / "bin" / "ck-herdr"
loader = importlib.machinery.SourceFileLoader("ck_herdr", str(path))
spec = importlib.util.spec_from_loader("ck_herdr", loader)
m = importlib.util.module_from_spec(spec)
loader.exec_module(m)

leaf = lambda t, w=None: {"type": "block", "id": "p" + t, "content": {"terminal": t},
                          **({"size": {"weight": w}} if w else {})}
# Herdr's own halving: main 0.5 | column(a 1, b 0.5) and a new pane c split right of b.
root = {"type": "row", "id": "tab1", "children": [
    leaf("main", 0.5),
    {"type": "column", "id": "s1", "size": {"weight": 0.5}, "children": [leaf("a"), leaf("b", 0.5)]},
    leaf("shell", 0.25), leaf("c", 0.25)]}
tree = m.beside_tree(root, "main", {"a", "b", "c"})
assert tree["id"] == "tab1" and tree["type"] == "row" and len(tree["children"]) == 2
left, right = tree["children"]
assert left["type"] == "column" and [x["content"]["terminal"] for x in left["children"]] == ["main", "shell"]
assert right["type"] == "column" and [x["content"]["terminal"] for x in right["children"]] == ["a", "b", "c"]
for node in [left, right, *left["children"], *right["children"]]:
    assert node["size"] == {"weight": 1.0}, node
# Ids of panes are kept (Herdr knows panes by id).
assert right["children"][0]["id"] == "pa"
# Only main and agents: main is a plain block on the left.
tree = m.beside_tree({"type": "row", "id": "t", "children": [leaf("main"), leaf("x")]}, "main", {"x"})
assert tree["children"][0]["content"]["terminal"] == "main"
# Main missing or no agent: nothing to do.
assert m.beside_tree({"type": "row", "id": "t", "children": [leaf("x")]}, "main", {"x"}) is None
assert m.beside_tree({"type": "row", "id": "t", "children": [leaf("main")]}, "main", set()) is None
print("PASS beside layout: main left half, agents right half, equal weights, other panes kept")
