## EssentialFeed Architecture (⚠️ still in progress.... ⚠️)

![Architecture_EssentialFeed](https://github.com/user-attachments/assets/567b2e5b-ea08-466c-898a-370775bd2d9c)


### Remote Feed Image Spec

| Property      | Type                |
|---------------|---------------------|
| `image_id`    | `UUID`              |
| `image_desc`  | `String` (optional) |
| `image_loc`   | `String` (optional) |
| `image_url`	| `URL`               |

### Payload contract

```
200 RESPONSE

{
	"items": [
		{
			"image_id": "a UUID",
			"image_desc": "a description",
			"image_loc": "a location",
			"image_url": "https://a-image.url",
		},
		{
			"image_id": "another UUID",
			"image_desc": "another description",
			"image_url": "https://another-image.url"
		},
		{
			"image_id": "even another UUID",
			"image_loc": "even another location",
			"image_url": "https://even-another-image.url"
		},
		{
			"image_id": "yet another UUID",
			"image_url": "https://yet-another-image.url"
		}
		...
	]
}
```
