# Pokemon searcher

## Considerations
The main consideration I took into account is that the unique identifier for each record is the name of the Pokemon. This, because the Pokedex number can be shared between different Pokemons, as seen here:

```
#,Name,Type 1,Type 2,Total,HP,Attack,Defense,Sp. Atk,Sp. Def,Speed,Generation,Legendary
...
3,Venusaur,Grass,Poison,525,80,82,83,100,100,80,1,False
3,VenusaurMega Venusaur,Grass,Poison,625,80,100,123,122,120,80,1,False
```

This project doesn't operate in a database, instead it manipulates the original CSV file.

## Available endpoints

### Paged results
`GET /pokemons?page=<number>&per_page=<number>`

If page and per_page params are not given, the default values are page = 0 and per_page = 20.

<b>Note: </b> The first page is the page 0, not 1.

### Create Pokemon
`POST /pokemons`

The input should like this:
```
{
  "pokemon": {
		"number": 1,
		"name": "Bulbasaur",
		"type1": "Grass",
		"type2": "Poison",
		"total": 318,
		"hp": 45,
		"attack": 49,
		"defense": 49,
		"sp_atk": 65,
		"sp_def": 65,
		"speed": 45,
		"generation": 1,
		"legendary": false
	}
}
```

The endpoint validates that:
* `number, name, type1, total, hp, attack, defense, sp_atk, sp_def, speed, generation` are present
* `number, total, hp, attack, defense, sp_atk, sp_def, speed, generation` are numbers
*  `name` it's unique, this means, there isn't any other Pokemon with that name

### Show Pokemon
`GET /pokemons/:name`

Returns a Pokemon searched by name. The format returned is:
```
{
  "success": true,
  "data": {
    "number": 4,
    "name": "Charmander",
    "type1": "Fire",
    "type2": null,
    "total": 309,
    "hp": 39,
    "attack": 54,
    "defense": 43,
    "sp_atk": 60,
    "sp_def": 50,
    "speed": 65,
    "generation": 1,
    "legendary": false
  },
  "message": ""
}
```

### Update Pokemon
`PUT | PATCH /pokemons/:name`

The input should be like:
```
{
	"pokemon": {
		"attack": 54
	}
}
```

You can change any field that applies for the create endpoint, except the name. It will run the same validations as the create endpoint, except for the unique name validation.

### Destroy Pokemon
`DELETE /pokemons/:name`

It deletes an existing Pokemon in the database.