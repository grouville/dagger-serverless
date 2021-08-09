package zip

import (
	"alpha.dagger.io/dagger"
	"alpha.dagger.io/alpine"
	"alpha.dagger.io/dagger/op"
)

// Zip an artifact
#Zip: {
	// Artifact to zip
	source: dagger.#Artifact & dagger.#Input

	// Zip name
	name: *"archive.zip" | string & dagger.#Input

	#up: [
		op.#Load & {
			from: alpine.#Image & {
				package: zip: true
			}
		},

		op.#Exec & {
			args: ["sh", "-c",
				#"""
					mkdir -p /output
					zip -r "/output/$ARCHIVE_NAME" *
					"""#,
			]
			dir: "/inputs"
			mount: "/inputs/": from: source
			env: ARCHIVE_NAME: name
		},

		op.#Subdir & {
			dir: "/output"
		},
	]
}
